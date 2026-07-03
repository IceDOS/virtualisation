# AGENTS.md — IceDOS **virtualisation**

> Utilizes the **IceDOS** framework. The full bible — module structure, config flow,
> the `icedos rebuild --build` test loop, `validate.*` helpers, dep loading — lives in
> **core**: <https://github.com/IceDOS/core/blob/main/AGENTS.md> — this file only
> covers what is specific to **virtualisation**.

## Non-negotiable rules (full detail in core)

- Build/test only via the `icedos` CLI — **never `sudo nixos-rebuild`**.
- **Never** `git commit/stash/reset/pull` — the user manages git.
- Every option uses a `validate.*`/`mk*Option` helper; **no untyped options**.
- A module's `config.toml` defaults must mirror its `icedos.nix` defaults.
- Format with `icedos nixf .` after editing any `.nix`.
- If a repo or the config root you need isn't checked out locally, **ask the user** for
  its path or permission to `git clone` it — don't guess or clone unprompted.

## Purpose

Containers, virtual machines, and emulation: Docker, Podman, libvirt/virt-manager,
VirtualBox, Waydroid. Everything that turns the host into a hypervisor or container runtime.

## Layout

- `modules/<name>/{icedos.nix,config.toml}` per module; `flake.nix` exposes them via
  `icedosLib.scanModules { path = ./modules; filename = "icedos.nix"; }`.

## Module shape here

Standard IceDOS module under `options.icedos.virtualisation.<name>`. Same shape as apps
(options from sibling `config.toml` → `outputs.nixosModules` → `meta.name`). Most modules
here are option-less (just flip the NixOS `virtualisation.<x>.enable` switch); only `docker`
declares options.

## Test a change to this repo

In the config root's `config.toml`, point this repo's `overrideUrl` at your local
checkout (`path:/abs/path/to/virtualisation`), then `icedos rebuild --build` (no activation).
Enabling a hypervisor/container runtime affects the running system — prefer `--build`
validation and let the user activate.

## Notable modules / gotchas

- `docker` (daemon settings, `requireSudo` group toggle), `podman`, `virt-manager`
  (libvirtd + IOMMU kernel params keyed off `icedos.hardware.cpus`), `virtualbox`
  (`vboxusers` group + `kvm.enable_virt_at_load=0` for kernel 6.13+), `waydroid`.
- `virt-manager` reads `icedos.hardware.cpus` and `virtualbox` reads `icedos.users` —
  both come from other repos already merged into the same config.
