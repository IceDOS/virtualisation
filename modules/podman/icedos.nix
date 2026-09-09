{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (
        { ... }:
        {
          virtualisation.podman.enable = true;

          icedos.system.tips.list = [
            "Podman runs an app in its own sealed box, and understands the same commands as Docker."
          ];
        }
      )
    ];

  meta.name = "podman";
}
