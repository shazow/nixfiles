{
  description = "shoe - FHS bubblewrap container for running";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildFHSEnv {
        name = "shoe";

        targetPkgs = p: with p; [
          coreutils
          bashInteractive
          bubblewrap
          cacert
        ];

        runScript = pkgs.writeShellScript "runner" ''
          exec bwrap \
            --ro-bind /nix /nix \
            --ro-bind /usr /usr \
            --ro-bind /bin /bin \
            --ro-bind /sbin /sbin \
            --ro-bind /lib /lib \
            --ro-bind /lib64 /lib64 \
            --ro-bind /etc/resolv.conf /etc/resolv.conf \
            --ro-bind /etc/hosts /etc/hosts \
            --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf \
            --ro-bind /etc/ssl/certs /etc/ssl/certs \
            --ro-bind-try /etc/static /etc/static \
            --dev-bind /dev /dev \
            --proc /proc \
            --tmpfs /tmp \
            --tmpfs "$HOME" \
            --ro-bind-try "$HOME/.nix-profile/bin" "$HOME/.nix-profile/bin" \
            --bind "$PWD" "$PWD" \
            -- bash -c 'if [ $# -eq 0 ]; then exec bash; else exec "$@"; fi' runner "$@"
        '';

        extraBwrapArgs = [
          "--cap-drop" "ALL"

          "--unshare-ipc"
          "--unshare-pid"
          "--unshare-uts"
          "--unshare-cgroup-try"

          # Uncomment the line below to kill all network access inside the sandbox.
          # "--unshare-net"
        ];
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/shoe";
      };
    };
}
