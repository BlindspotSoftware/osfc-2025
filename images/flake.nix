{
  description = "image FirmwareCI Test Image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    firmwareci-base-image = {
      url = "github:BlindspotSoftware/firmwareci-base-image/8640af8454a4ea86af01e2ba9eafcbff89a0441e";
    };
  };

  outputs = { self, flake-utils, nixpkgs, pre-commit-hooks, firmwareci-base-image, ... }:
    let
      fsType = "ext4";

      imageConfig = { config, pkgs, ... }: {
        imports = [
          ./modules/ssh.nix
        ];
        networking.hostName = "odroid";

        # Enable avahi for mDNS hostname resolution
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          nssmdns6 = true;
          publish = {
            enable = true;
            addresses = true;
            hinfo = true;
            workstation = true;
            domain = true;
          };
        };

        # Configure networking for stable interface names
        networking = {
          useDHCP = false;
          interfaces.enp1s0.useDHCP = true;
          # Ensure consistent interface naming
          usePredictableInterfaceNames = true;
        };

        # Install lm-sensors for hardware monitoring
        environment.systemPackages = with pkgs; [
          lm_sensors
        ];

        firmwareci.kernel = {
          version = "6.16.6";
          sha256 = "sha256-SLV7Hi4hZvtgGg4DXS+2OW4pXZJF8N/WiD18DIOLMAI=";
        };
        # Disable ZFS to avoid kernel compatibility issues
        boot.supportedFilesystems = pkgs.lib.mkForce [ "ext4" "vfat" "ntfs" "btrfs" ];
        # Configure GRUB for UEFI boot with fallback
        boot.loader = {
          systemd-boot.enable = pkgs.lib.mkForce false;
          grub = {
            enable = pkgs.lib.mkForce true;
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "nodev";
          };
          efi.canTouchEfiVariables = false;
        };
      };

      generateDiskImage = { config, fsType, pkgs }:
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          inherit config fsType pkgs;
          inherit (nixpkgs) lib;
          partitionTableType = "efi";
          additionalSpace = "0";
        };
    in
    flake-utils.lib.eachSystem (with flake-utils.lib.system; [ x86_64-linux ])
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (firmwareci-base-image.outputs) baseConfig;

          nixosConfigurations = {
            default = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                baseConfig
                imageConfig
              ];
            };
          };
        in
        {
          inherit nixosConfigurations;

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                statix.enable = true;
              };
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ statix ];
            shellHook = ''
              ${self.checks.${system}.pre-commit-check.shellHook}
            '';
          };

          packages = {
            odroid = generateDiskImage {
              inherit fsType pkgs;
              inherit (nixosConfigurations.default) config;
            };
          };
        }
      );
}
