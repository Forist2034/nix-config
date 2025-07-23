const flake = path self ../..

const hostname = "nixos-sbc0"

const part_esp = "/dev/disk/by-partlabel/sbc0-sd-esp"
const part_images = "/dev/disk/by-partlabel/sbc0-sd-images"
const part_state = "/dev/disk/by-partlabel/sbc0-sd-state"
const part_root = "/dev/disk/by-partlabel/sbc0-sd-root"

def nix_build [--out-dir: string, name: string, attr: string] {
  let flakeUri = $"($flake)#nixosConfigurations.($hostname).config.($attr)"
  nix build --keep-going -j 1 --out-link ($out_dir | path join $name) $flakeUri
}

def copy_contents [src: string, dest: string] {
  ls $src | each {|c| cp -r $c.name $dest }
}

export module reset {
  export def esp [] {
    # must set -F and -S, or the system can't boot
    mkfs.vfat -F 32 -S 512 -n sbc0-sd-esp -v $part_esp
  }

  def reset_ext4 [path: string] {
    wipefs $path
    mkfs.ext4 -L sbc0-images $path
  }
  export def state [] {
    reset_ext4 $part_state
  }
  export def images [] {
    reset_ext4 $part_images
  }
}

export module uboot {
  export def write [disk: string] {
    let bin_file = $env.OUT_DIR | path join "toplevel/etc/uboot/u-boot-sunxi-with-spl.bin"
    dd $"if=($bin_file)" $"of=($disk)" bs=1024 seek=8 oflag=sync
  }
}

export module image {
  const output_name = "image"
  
  export def build [] {
    nix_build --out-dir $env.OUT_DIR $output_name "system.build.images.ro-image"
  }
  
  def repart_info [out: string] {
    $out | path join "repart-output.json" | open -r | from json
  }
  def boot_info_file [out: string, output: list] {
    let name = $output | filter {|part| $part.label == "boot-info" } | first
    $out | path join $name.split_path
  }
  def root_file [out: string, output: list] {
    let name = $output | filter {|part| $part.label | str starts-with "sbc0-root" } | first
    $out | path join $name.split_path
  }

  def write_boot [info_path: string] {
    let esp_mount = mktemp --directory
    mount -v $part_esp $esp_mount
    copy_contents ($info_path | path join "boot") $esp_mount
    umount $esp_mount
    rm --permanent $esp_mount
  }
  def write_image [--boot-info: string, --root: string, info_path: string] {
    let image_mount = mktemp --directory 
    mount -v $part_images $image_mount
    let filenames = open -r ($info_path | path join "filenames.json") | from json
    cp -v $boot_info ($image_mount | path join ($filenames | get "boot-info"))
    cp -v $root ($image_mount | path join $filenames.root)
    umount -v  $image_mount
    rm --permanent $image_mount
  }

  export def write [--build] {
    if $build {
      build
    }

    let out = $env.OUT_DIR | path join $output_name
    let repart_output = repart_info $out 
    let boot_info = boot_info_file $out $repart_output
    
    let info_path = mktemp --directory 
    mount -v $boot_info $info_path
    write_boot $info_path
    write_image --boot-info $boot_info --root (root_file $out $repart_output) $info_path
    umount -v $info_path
    rm --permanent $info_path
  }

  export def update [--build] {
    if $build {
      build
    }

    let out = $env.OUT_DIR | path join $output_name
    let repart_output = repart_info $out
    let boot_info = boot_info_file $out $repart_output
    let root = root_file $out $repart_output

    let info_path = mktemp --directory 
    erofsfuse $boot_info $info_path

    let filenames = $info_path | path join "filenames.json" | from json
    
    scp $root $"root@($hostname):/mnt/images/($filenames.root)"
    scp $boot_info $"root@($hostname):/mnt/images/($filenames | get "boot-info")"

    let uki_path = $"boot/EFI/Linux/($filenames.uki)"
    scp $"($info_path)/($uki_path)" $"root@($hostname):/($uki_path)"
    
    fusermount -u $info_path
    rm --permanent $info_path
  }
}

export module system {
  export def build [] {
    nix_build --out-dir $env.OUT_DIR "toplevel" "system.build.toplevel"
  }

  export def first-boot [] {
    ssh $"root@($hostname)" bash "/mnt/root/etc/first-boot.sh"
  }

  export module rebuild {
    def remote_rebuild [op: string] {
      nixos-rebuild $op --flake $"($flake)#($hostname)" --keep-going -j 1 --target-host $"root@($hostname)"
    }

    export def test [] {
      remote_rebuild test
    }
  }

  export module image {
    const output_name = "system-image"

    export def build [] {
      nix_build --out-dir $env.OUT_DIR $output_name "system.build.images.system"
    }

    def write_boot [out: string] {
      use reset
      reset esp

      let img_path = mktemp --directory 
      let part_path = mktemp --directory 
      mount -v ($out | path join "system-image.esp.raw") $img_path
      mount -v $part_esp $part_path

      copy_contents $img_path $part_path

      umount -v $img_path
      umount -v $part_path
      rm --permanent $img_path
      rm --permanent $part_path
    }
    def write_root [out: string] {
      dd $"if=($out | path join "system-image.root.raw")" $"of=($part_root)" bs=4k status=progress
      sync
    }

    export def write [--build] {
      if $build {
        build
      }

      let out = $env.OUT_DIR | path join $output_name
      write_boot $out
      write_root $out
    }
  }
}
