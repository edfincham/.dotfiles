{ config, pkgs, lib, ... }:

{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-$UUID".device = "/dev/disk/by-uuid/$UUID";

  # Bluetooth configuration
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # WiFi driver power management for suspend/resume
  # Unload the WiFi driver before suspend and reload after resume
  powerManagement.powerDownCommands = ''
    ${pkgs.kmod}/bin/modprobe -r mt7925e
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/modprobe mt7925e
  '';

  # Lock screen before suspend service
  systemd.services.i3lock-before-sleep = {
    description = "Lock screen before suspend";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      User = "ed";
      Type = "forking";
      ExecStart = "${pkgs.bash}/bin/sh /home/ed/.config/i3/lock.sh";
      TimeoutStartSec = "infinity";
    };
  };
}
