{
  primaryUsername ? "shazow",
  guestUsername ? "andrey",
  initialHashedPassword,
  ...
}:
{
  users.users.${primaryUsername} = {
    isNormalUser = true;
    home = "/home/${primaryUsername}";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "adbusers" "docker" "i2c" ];
    uid = 1000;
    initialHashedPassword = initialHashedPassword;
  };

  # Guest user
  users.users.${guestUsername} = {
    isNormalUser = true;
    home = "/home/${guestUsername}";
    uid = 1100;
    initialHashedPassword = initialHashedPassword;
  };
}
