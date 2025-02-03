{ ... }:
{
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
      status = {
        disabled = false;
        pipestatus = true;
        map_symbol = true;
        format = "[$symbol $int $common_meaning(SIGNAL $signal_name\\($signal_number\\))]($style) ";
        pipestatus_format = "\\[$pipestatus\\] => [$symbol $int $common_meaning(SIGNAL $signal_name\\($signal_number\\))]($style) ";
      };
    };
  };
}
