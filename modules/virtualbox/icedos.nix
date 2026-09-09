{ icedosLib, ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (
        {
          config,
          ...
        }:
        let
          inherit (config.icedos) users;
          inherit (icedosLib.users) mkGroupInjector;
        in
        {
          virtualisation.virtualbox.host.enable = true;

          boot.kernelParams = [
            # Allow VirtualBox to run on kernel 6.13+
            "kvm.enable_virt_at_load=0"
          ];

          users.users = mkGroupInjector "vboxusers" users;

          icedos.system.tips.list = [
            "VirtualBox runs another operating system in a window, and supports snapshots which puts it back the way it was if something breaks."
            "VirtualBox needs its Guest Additions installed inside the virtual machine to resize its window and share folders with it."
          ];
        }
      )
    ];

  meta.name = "virtualbox";
}
