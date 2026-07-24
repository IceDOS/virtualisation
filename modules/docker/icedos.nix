{ icedosLib, lib, ... }:

{
  options.icedos.virtualisation.docker =
    let
      inherit (icedosLib) mkAttrsOption mkBoolOption;
      inherit (lib) importTOML;

      inherit ((importTOML ./config.toml).icedos.virtualisation.docker)
        daemonSettings
        requireSudo
        ;
    in
    {
      daemonSettings = mkAttrsOption { default = daemonSettings; };
      requireSudo = mkBoolOption { default = requireSudo; };
    };

  outputs.nixosModules =
    { ... }:
    [
      (
        {
          config,
          lib,
          ...
        }:

        let
          inherit (lib) mapAttrs mkIf;
          inherit (config.icedos) users virtualisation;
          inherit (virtualisation.docker) daemonSettings requireSudo;
        in
        {
          virtualisation.docker = {
            enable = true;
            daemon.settings = daemonSettings;
          };

          users.users = mapAttrs (_: _: {
            extraGroups = mkIf (!requireSudo) [ "docker" ];
          }) users;
        }
      )
    ];

  meta.name = "docker";
}
