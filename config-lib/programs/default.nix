args: {
  firefox = import ./firefox.nix;
  helix = import ./helix.nix;
  nixvim = import ./nixvim.nix args;
  vscodium = import ./vscodium.nix args;
}
