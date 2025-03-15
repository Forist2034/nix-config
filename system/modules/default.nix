libs: {
  persistence = import ./persistence.nix;
  tools = (import ./tools) libs;
  thunderbird = (import ./thunderbird.nix) libs;
}
