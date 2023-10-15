{
  initialHashedPassword,
  ...
}:
{
  # Guest user
  users.users.andrey = {
    isNormalUser = true;
    home = "/home/andrey";
    description = "andrey";
    uid = 1100;
    initialHashedPassword = initialHashedPassword;
  };
}
