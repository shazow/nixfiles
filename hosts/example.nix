{
  boot.blacklistedKernelModules = [ "mei_me" ];
  imports = [
    ./common/desktop.nix
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
  ];
  networking.hostName = "examplehost";

  users.extraUsers.exampleuser = {
    isNormalUser = true;
    home = "/home/exampleuser";
    description = "Example";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager"];
    uid = 1000;
    hashedPassword = let hashedPassword = import ../.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };
}
