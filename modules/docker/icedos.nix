{ icedosLib, lib, ... }:

{
  options.icedos.virtualisation.docker =
    let
      inherit (icedosLib) mkAttrsOption mkEitherOption;
      inherit (lib) importTOML types;

      inherit ((importTOML ./config.toml).icedos.virtualisation.docker)
        daemonSettings
        privilegedUsers
        ;
    in
    {
      daemonSettings = mkAttrsOption { default = daemonSettings; };

      # Users granted the `docker` group, or "all" to grant it to every user.
      # docker access is root equivalent, so this must stay an explicit
      # allowlist by default (default: nobody — everyone reaches docker via
      # sudo). The string branch is constrained to the literal "all" so a
      # typo'd or bare-username string fails eval here with a readable type
      # error instead of crashing inside elem downstream.
      privilegedUsers = mkEitherOption { default = privilegedUsers; } (types.addCheck types.str (
        v: v == "all"
      )) (types.listOf types.str);
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
          inherit (lib) elem mapAttrs mkIf;
          inherit (config.icedos) users virtualisation;
          inherit (virtualisation.docker) daemonSettings privilegedUsers;
          # "all" grants the group to every user; otherwise an explicit list.
          dockerGroupFor = n: privilegedUsers == "all" || elem n privilegedUsers;
        in
        {
          virtualisation.docker = {
            enable = true;
            daemon.settings = daemonSettings;
          };

          # docker access is root equivalent — grant the group only to the
          # explicit privilegedUsers allowlist (or every user when "all"),
          # never by default.
          users.users = mapAttrs (n: _: {
            extraGroups = mkIf (dockerGroupFor n) [ "docker" ];
          }) users;
        }
      )
    ];

  meta.name = "docker";
}
