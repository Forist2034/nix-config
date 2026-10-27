lib: with lib; {
  inherit lib;

  options = {
    mkDisableOption =
      description:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        inherit description;
      };
  };
}
