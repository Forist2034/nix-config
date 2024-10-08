libs: {
  nix = import ./nix.nix;
  tools = import ./tools;
  modules = (import ./modules) libs;
  dict = import ./dict.nix;
  mobile-sync = import ./mobile-sync.nix;
  smart = import ./smart.nix;
}
