{ pkgs, ... }:
{
  services.dictd = {
    enable = true;
    DBs = with pkgs.dictdDBs; [
      wordnet
      wiktionary
    ];
  };

  environment.systemPackages = [ pkgs.dict ];
}
