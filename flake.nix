{
  description = "Lidarr distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      lidarr-image = pkgs.dockerTools.buildLayeredImage {
        name = "lidarr";
        tag = "latest";
        contents = [
          pkgs.lidarr
          pkgs.cacert
          pkgs.tzdata
        ];
        config = {
          Env = [
            "COMPlus_EnableDiagnostics=0"
            "TMPDIR=/run/lidarr-temp"
          ];
          ExposedPorts = {
            "8686/tcp" = {};
          };
          Volumes = {
            "/config" = {};
            "/data" = {};
          };
          # Tell lidarr to use /config as its data directory
          Cmd = [ "${pkgs.lidarr}/bin/Lidarr" "-data=/config" "-nobrowser" ];
          # Distroless non‑root user
          User = "1000";
          WorkingDir = "/config";
        };
      };
    };

    # Expose the lidarr version for CI workflows
    lidarrVersion = pkgs.lidarr.version;

    defaultPackage.${system} = self.packages.${system}.lidarr-image;
  };
}
