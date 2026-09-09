{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      {
        virtualisation.waydroid.enable = true;

        icedos.system.tips.list = [
          "Waydroid runs Android apps on this desktop, each in its own window."
          "Start Android with waydroid session start, then open it with waydroid show-full-ui."
        ];
      }
    ];

  meta.name = "waydroid";
}
