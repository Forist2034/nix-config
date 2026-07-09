{ ... }: {
  home = {
    default = { ... }: {
      programs.direnv = {
        enable = true;
      };
    };
  };
}
