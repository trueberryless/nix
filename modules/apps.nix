{ pkgs, system, ...}: 
{
  environment.systemPackages = with pkgs; [
    aldente
    gh
    neofetch
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
