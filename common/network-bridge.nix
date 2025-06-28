# Network bridge used for VMs
# Via https://astro.github.io/microvm.nix/simple-network.html
_:
{
  systemd.network.enable = true;

  systemd.network.networks."10-lan" = {
    matchConfig.Name = [
      "eno1"
      "vm-*"
    ];
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = [
        "192.168.1.2/24"
        "2001:db8::a/64"
      ];
      Gateway = "192.168.1.1";
      DNS = [ "192.168.1.1" ];
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
