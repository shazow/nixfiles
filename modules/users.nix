{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixfiles.users;
in {
  options.nixfiles.users = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable user configuration";
    };
       
    primaryUsername = mkOption {
      type = types.str;
      default = "shazow";
      description = "Primary user on the device";
    };

    guestUsername = mkOption {
      type = types.str;
      default = "andrey";
      description = "Additional guest user to create";
    };

    initialHashedPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Initial password hash to set for users";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.primaryUsername} = {
      isNormalUser = true;
      home = "/home/${cfg.primaryUsername}";
      extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "adbusers" "docker" "i2c" ];
      uid = 1000;
      initialHashedPassword = cfg.initialHashedPassword;
    };

    # Guest user
    users.users.${cfg.guestUsername} = {
      isNormalUser = true;
      home = "/home/${cfg.guestUsername}";
      uid = 1100;
      initialHashedPassword = cfg.initialHashedPassword;
    };
  };
}
