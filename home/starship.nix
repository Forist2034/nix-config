{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      username.show_always = true;
      shell = {
        disabled = false;
        style = "blue bold";
      };
      shlvl = {
        disabled = false;
        threshold = 1;
      };
    };
  };
}
