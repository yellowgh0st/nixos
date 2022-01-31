{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelParams = [ "quiet" "vt.global_cursor_default=0" "loglevel=0" "rd.systemd.show_status=false" "rd.udev.log_level=0" ];
  boot.kernel.sysctl = { "kernel.printk" = "0 0 0 0"; };
  #boot.extraModulePackages = with config.boot.kernelPackages; [
  #
  #];
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  services.udev.extraRules =  ''
   ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0",ATTR{queue/scheduler}="none"
  '';
  networking.hostName = "nixxx";
  networking.networkmanager.enable = true;
  #networking.extraHosts = ''
  #''

  time.timeZone = "Europe/Prague";

  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";
  networking.networkmanager.dns = "none";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.pantheon.enable = false;
  services.xserver.displayManager.lightdm.enable = false;  
  xdg.portal.enable = true;
  programs.xwayland.enable = true;
  services.flatpak.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.opengl.extraPackages = with pkgs; [
   rocm-opencl-icd
   rocm-opencl-runtime
   vaapiVdpau
   libvdpau-va-gl
  ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };

  users.users.augustin = {
     isNormalUser = true;
     extraGroups = [ "wheel" "video" "docker" ];
  };

  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    bpytop
    git
    pass
    qrencode
    yarn
    htop
    lm_sensors
    unzip
    irssi
    tree
    wl-clipboard
    nodejs
    clinfo
    #wine64Packages.stagingFull
    #wine64Packages.fonts
    winetricks
    wine-staging
    liquidctl
    docker-compose
    nixpkgs-fmt
    keybase-gui
    brave
    firefox
    discord
    tdesktop
    slack
    appeditor
    vscode-fhs
    inkscape
    gimp
    corectrl
    gnome.dconf-editor
    transmission-gtk
    gcolor3
    inkscape
    gnomeExtensions.arcmenu
    gnomeExtensions.caffeine
    gnomeExtensions.just-perfection
    gnomeExtensions.hide-minimized
    gnomeExtensions.tray-icons-reloaded
    gnome.gnome-tweaks
    nodePackages.vercel
  ];

  nixpkgs.overlays = [ 
      (import ./overlays/arcmenu.nix)
   ];

  virtualisation.docker.enable = true;

  programs.steam.enable = true;

  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.theme = "steeef";
  programs.zsh.ohMyZsh.plugins = [ "git" "kubectl" "pass" ];

  environment.shellAliases = {
    sensors = "watch -n 2 sensors";
    lightning-effect-1 = "liquidctl set led2 color backwards-marquee-5 2f6017 --speed slowest";
    lightning-effect-2 = "liquidctl set led2 color rainbow-flow --speed slowest";
    qr = ''qrencode -m 2 -t utf8 <<< "$1"'';
    bashtop = "bpytop";
    switch = "sudo nixos-rebuild switch";
    git-sync-kovan = "git checkout testing && git merge kovan && git push origin testing && git checkout staging && git merge kovan && git push origin staging && git checkout main && git merge staging && git push origin main";
  };

  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      doh_servers = true;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  services.keybase.enable = true;
  services.kbfs.enable = true; 
  services.openssh.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  
  networking.firewall.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
  system.stateVersion = "21.11";
}
