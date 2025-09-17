{ hostname, username, ... }:
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    description = username;
  };
  system.primaryUser = username;

  nix.settings.trusted-users = [ username ];
}
