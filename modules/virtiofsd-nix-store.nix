# virtiofsd for /nix/store with socket activation to be run as root.
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixfiles.virtiofs-nix-store;
in
{
  options.nixfiles.virtiofs-nix-store = {
    enable = mkEnableOption "virtiofsd for read-only /nix/store share";

    socketGroup = mkOption {
      type = types.str;
      default = "kvm";
      description = "Group owning the virtiofsd socket";
    };
  };

  config = mkIf cfg.enable {
    systemd.sockets."virtiofs-nix-store" = {
      description = "Socket for virtiofsd /nix/store read-only share";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "/run/virtiofs-nix-store.sock";
        SocketGroup = cfg.socketGroup;
        SocketMode = "0660";
      };
    };

    systemd.services."virtiofs-nix-store" = {
      description = "virtiofsd for /nix/store";
      requires = [ "virtiofs-nix-store.socket" ];
      after = [ "virtiofs-nix-store.socket" ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Group = "root";
        LimitNOFILE = 1048576;

        ExecStart = pkgs.writeShellScript "virtiofsd-wrapper" ''
          exec ${pkgs.virtiofsd}/bin/virtiofsd \
            --fd=3 \
            --shared-dir=/nix/store \
            --thread-pool-size $(${pkgs.coreutils}/bin/nproc) \
            --posix-acl \
            --xattr \
            --cache=auto \
            --inode-file-handles=mandatory \
            --readonly
        '';

        # virtiofsd has its own privilege dropping, but we add extra hadrening
        # to make debugging more fun.

        ProtectSystem = "strict";
        ProtectHome = true;
        ReadOnlyPaths = [ "/nix/store" ];
        PrivateTmp = true;
        PrivateDevices = true;

        PrivateNetwork = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];

        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;

        NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
