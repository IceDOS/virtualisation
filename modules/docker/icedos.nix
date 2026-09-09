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

      # docker access is root equivalent — grant the group only to an explicit
      # allowlist of usernames, or the literal "all" (constrained to fail on typos).
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

          # docker access is root equivalent — group granted only to
          # privilegedUsers (or every user when "all"), never by default.
          users.users = mapAttrs (n: _: {
            extraGroups = mkIf (dockerGroupFor n) [ "docker" ];
          }) users;

          icedos.system.tips.list = [
            ''Docker asks for your password every time, unless privilegedUsers under [icedos.virtualisation.docker] has your name, or is set to "all".''
            "Anyone listed in privilegedUsers option of Docker can take over the whole computer through it, so add only users you trust."
          ];
        }
      )
    ];

  meta.name = "docker";
}
