def cargo_cache [] {
  ls ~/.cargo/registry/cache | get name
}

export def "add crate" [name: string, version: string] {
  let local_name = $"($name)-($version).crate"
  let path =  cargo_cache  | each {$in | path join $local_name} 
    | filter {$in | path exists }
  if ($path | is-empty) {
    print $"($name) ($version) not found"
  } else {
    nix-prefetch-url --name $"crate-($name)-($version).tar.gz" $"file://($path | first)"
  }
}

export def "add locks" [lock: string] {
  open --raw $lock | from toml | get package
    | each {|pkg| add crate $pkg.name $pkg.version }
}
