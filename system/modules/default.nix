libs: {
  persistence = import ./persistence.nix;
  tools = (import ./tools) libs;
}
