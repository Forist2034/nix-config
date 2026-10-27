{
  persist,
  options,
  lib,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "java";
    options = {
      gradle.enable = lib.mkEnableOption "Gradle";
      maven.enable = lib.mkEnableOption "Maven";
    };
    config =
      { value, ... }:
      lib.mkMerge [
        (lib.mkIf value.gradle.enable { directories = [ ".gradle" ]; })
        (lib.mkIf value.maven.enable { directories = [ ".m2" ]; })
      ];
  };
}
