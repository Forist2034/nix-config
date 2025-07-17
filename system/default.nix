args: {
  nix = import ./nix.nix;
  tools = import ./tools;
  modules = (import ./modules) args;
  dict = import ./dict.nix;
  mobile-sync = import ./mobile-sync.nix;
  smart = import ./smart.nix;
}
