{
  boot.tmp.cleanOnBoot = true;
  preservation = {
    enable = true;

    preserveAt."/persistent" = {
      directories = [
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/systemd/timers"
        "/var/db/sudo/lectured"
        "/var/log"
        "/etc/NetworkManager/system-connections"
        "/var/cache"
        "/etc/ssh"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/tmp";
          mode = "1777";
        }
        {
          directory = "/var/tmp";
          mode = "1777";
        }
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      users.marco = {
        directories = [
          ".ssh"
          ".cache"
          ".local/share"
          ".local/state"
	  ".config/dconf"
	  ".config/librewolf"
          ".steam"
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Projects"
	  "Videos"
          "nixos-config"
        ];

        files = [
        ];
      };

    };
  };
}
