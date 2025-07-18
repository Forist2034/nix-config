{ config, lib, ... }:
{
  options = with lib; {
    persistence = mkOption {
      type = types.attrsOf (
        types.submodule {
          options =
            let
              fileList = mkOption {
                type = types.listOf types.anything;
                default = [ ];
              };
            in
            {
              share = {
                enable = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether shared with different user";
                };
              };
              persistStorageRoot = mkOption {
                type = types.str;
                description = "Persist storage root";
              };
              files = fileList;
              directories = fileList;
              users = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      files = fileList;
                      directories = fileList;
                    };
                  }
                );
                default = { };
              };
            };
        }
      );
    };

    init-shared-persist = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            persistStorageRoot = mkOption {
              type = types.str;
              description = "Persist storage root";
            };
            users = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    files = mkOption {
                      type = types.listOf types.anything;
                      default = [ ];
                    };
                    directories = mkOption {
                      type = types.listOf types.anything;
                      default = [ ];
                    };
                  };
                }
              );
            };
          };
        }
      );
    };
  };
  config = {
    environment.persistence = lib.mkMerge (
      builtins.attrValues (
        builtins.mapAttrs (name: config: {
          "${config.persistStorageRoot}" = {
            inherit (config) files directories;
            users = builtins.mapAttrs (user: value: {
              inherit (value) files;
              directories =
                if config.share.enable then [ "Shared/${name}" ] ++ value.directories else value.directories;
            }) config.users;
          };
        }) config.persistence
      )
    );

    init-shared-persist = builtins.mapAttrs (
      name: value:
      lib.mkIf value.share.enable {
        inherit (value) persistStorageRoot;
        users = builtins.mapAttrs (user: cfg: { inherit (cfg) files directories; }) value.users;
      }
    ) config.persistence;

    environment.etc =
      let
        # convert to attr and back to sort and deduplicate
        sortUniq =
          l:
          builtins.attrNames (
            builtins.listToAttrs (
              builtins.map (e: {
                name = e;
                value = null;
              }) l
            )
          );

        sharedPaths =
          {
            name,
            persistStorageRoot,
            config,
          }:
          let
            dirSubPaths = builtins.map (
              d: lib.path.subpath.components (if builtins.isString d then d else d.directory)
            ) config.directories;
            fileSubPaths = builtins.map (
              f: lib.path.subpath.components (if builtins.isString f then f else f.file)
            ) config.files;
          in
          {
            parents = sortUniq (
              builtins.map (f: lib.path.subpath.join (lib.lists.init f)) (dirSubPaths ++ fileSubPaths)
            );
            directories = sortUniq (builtins.map lib.path.subpath.join dirSubPaths);
            files = sortUniq (builtins.map lib.path.subpath.join fileSubPaths);
          };

        mkSharedInitScript =
          {
            name,
            persistStorageRoot,
            paths,
          }:
          let
            dataPath = p: "${persistStorageRoot}/home/${name}/${p}";
          in
          ''
            #!/bin/sh

            set -o errexit

            # create parent directories
            ${builtins.concatStringsSep "\n" (
              builtins.map (d: "mkdir -pv \"${dataPath d}\"") (sortUniq paths.parents)
            )}

            # create directories
            ${builtins.concatStringsSep "\n" (
              builtins.map (d: "mkdir -pv \"${dataPath d}\"") (sortUniq paths.directories)
            )}

            # create files
            ${builtins.concatStringsSep "\n" (
              builtins.map (f: "touch \"${dataPath f}\"") (sortUniq paths.files)
            )}
          '';

        mkUserLinkScript =
          {
            name,
            persistStorageRoot,
            user,
            paths,
          }:
          let
            dataPath = p: "${persistStorageRoot}/home/${name}/${p}";
            userPath = p: "${persistStorageRoot}/home/${user}/${p}";
          in
          ''
            #!/bin/sh

            set -o errexit

            function link_dir() {
              if [[ ! -e "$2" ]]
              then
                ln -sv "$1" "$2"
              else
                echo "skip linking '$1' -> '$2'"
              fi
            }

            function link_file() {
              if [[ ! -e "$2" ]]
              then
                ln -v "$1" "$2"
              else
                echo "skip linking '$1' => '$2'"
              fi
            }

            # create parent directories
            ${builtins.concatStringsSep "\n" (builtins.map (d: "mkdir -pv \"${userPath d}\"") paths.parents)}

            # link directories
            ${builtins.concatStringsSep "\n" (
              builtins.map (d: "link_dir \"${dataPath d}\" \"${userPath d}\"") paths.directories
            )}

            # hard link files
            ${builtins.concatStringsSep "\n" (
              builtins.map (f: "link_file \"${dataPath f}\" \"${userPath f}\"") paths.files
            )}

            # create shared dir link
            mkdir -pv "${userPath "Shared"}"
            link_dir "${persistStorageRoot}/home/${name}" "${userPath "Shared/${name}"}"
          '';
      in
      builtins.listToAttrs (
        builtins.concatLists (
          builtins.attrValues (
            builtins.mapAttrs (
              name: value:
              let
                userPaths = builtins.mapAttrs (
                  _: config:
                  sharedPaths {
                    inherit (value) persistStorageRoot;
                    inherit name config;
                  }
                ) value.users;
              in
              [
                {
                  name = "init-persist/${name}/init.sh";
                  value = {
                    text = mkSharedInitScript {
                      inherit name;
                      inherit (value) persistStorageRoot;
                      paths = builtins.zipAttrsWith (_: paths: builtins.concatLists paths) (
                        builtins.attrValues userPaths
                      );
                    };
                  };
                }
              ]
              ++ builtins.attrValues (
                builtins.mapAttrs (user: paths: {
                  name = "init-persist/${name}/user/${user}.sh";
                  value = {
                    text = mkUserLinkScript {
                      inherit (value) persistStorageRoot;
                      inherit name user paths;
                    };
                  };
                }) userPaths
              )
            ) config.init-shared-persist
          )
        )
      );
  };
}
