{
  boot.blacklistedKernelModules = [ "mei_me" ];
  imports = [
    ./common/server.nix
  ];
  networking.hostName = "examplehost";

  users.extraUsers.exampleuser = {
    isNormalUser = true;
    home = "/home/exampleuser";
    description = "Example";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager"];
    uid = 1000;
    hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };
}
