{ icedosLib, ... }:

{
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
          inherit (lib) mapAttrs optional;
          inherit (config.icedos) users;
        in
        {
          programs.virt-manager.enable = true;

          virtualisation = {
            libvirtd.enable = true;
            spiceUSBRedirection.enable = true;
          };

          users.users = mapAttrs (_: _: {
            extraGroups = [ "libvirtd" ];
          }) users;

          boot.kernelParams = [
            # Allows passthrough of independent devices, that are members of larger IOMMU groups
            # It only affects kernels with ACS Override support. Ex: CachyOS, Liquorix, Zen
            "pcie_acs_override=downstream,multifunction"
          ]
          ++ optional (icedosLib.hasModule {
            inherit config;
            url = "github:icedos/hardware";
            name = "ryzen";
          }) "amd_iommu=on"
          ++ optional (icedosLib.hasModule {
            inherit config;
            url = "github:icedos/hardware";
            name = "intel";
          }) "intel_iommu=on";

          icedos.system.tips.list = [
            "Virt-manager can hand a real graphics card to a virtual machine, so games and 3D run at full speed in it."
            "Virt-manager can pass a USB stick, webcam or printer plugged into this computer into a running virtual machine."
          ];
        }
      )
    ];

  meta.name = "virt-manager";
}
