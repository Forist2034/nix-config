#!/usr/bin/env nu

def main [--src: string, --dest: string] {
  let dest = [$dest, (date now | format date "%Y-%m")] | path join
  mkdir -v $dest
  ls $src | each {|f| mv -v $f.name $dest }
}
