libs: {
  nix = import ./nix.nix;
  tools = import ./tools;
  modules = (import ./modules) libs;
}
