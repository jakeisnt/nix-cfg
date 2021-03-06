{ config, lib, pkgs, inputs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  # https://github.com/yegortimoshenko/yegortimoshenko-flake/blob/master/profiles/hardware/dell-xps/9380/default.nix
  boot = {
    consoleLogLevel = 1;
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" "usb_storage" ];
      kernelModules = [ "dm-snapshot" "i915" ];
      checkJournalingFS = true;
    };

    kernelModules = [ "kvm-intel" "dm-snapshot" "i915" ];
    kernel.sysctl = {
      # enable ipv6 privacy extensions and prefer using temp addresses
      "net.ipv6.conf.all.use_tempaddr" = 2;
      "max_user_instances" = 8192;
      "max_user_watches" = 16834;
    };
    kernelParams = [
      # disable spectre and meltdown fixes
      "mitigations=off"
      # 4k video config
      "video=eDP-1:3840x2160@60"
      # fast quiet boot
      "quiet"
      "splash"
      "vga=current"
      "i915.fastboot=1"
      "loglevel=3"
      "systemd.show_status=auto"
      "udev.log_priority=3"
      # force power savings when possible
      "iwlwifi.power_save=Y"
      "pcie_aspm=force"
      # Optimize xps battery; causes framebuffer issues on some devices
      "i915.semaphores=1"
      "i915.enable_fbc=1"
      "i915.enable_psr=2"
      "i915.enable_rc6=7"
      "i915.lvds_downclock=1"
    ];
  };

  # scanning
  hardware = {
    sane.enable = true;
    opengl.enable = true;
    # enable machine check exception error logs
    mcelog.enable = true;
  };

  # CPU
  nix.maxJobs = lib.mkDefault 8;
  # "powersave" for the obvious
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = true;

  # Power management
  environment.systemPackages = [ pkgs.acpi ];
  powerManagement.powertop.enable = true;
  # Monitor backlight control
  programs.light.enable = true;
  user.extraGroups = [ "video" ];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    # keep file system from recording on file visit
    options = [ "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/786f7e92-74b5-4327-873a-89905a173f86"; }];

  # Undervolt

  # Note that this is incredibly device specific.
  # If you're copying this config, there is no guarantee
  # that you'll be able to get away with these values.
  services.undervolt = {
    enable = true;
    coreOffset = -80;
    gpuOffset = -80;
    uncoreOffset = -80;
  };

  services = {
    # https://github.com/NixOS/nixos-hardware/pull/127
    throttled.enable = lib.mkDefault true;
    # https://wiki.archlinux.org/index.php/Dell_XPS_13_(9370)#Thermal_Throttling
    thermald.enable = lib.mkDefault true;
  };
}
