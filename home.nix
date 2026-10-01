{ config, pkgs, inputs, ... }: 
let
	downloadWallpapers = pkgs.writeShellApplication {
		name = "download-wallpapers";
		text = builtins.readFile ./download-wallpapers.sh;
	};
  # Watches ~/.local/state/caelestia/scheme.json and forwards it to the
  # extension over Firefox's native-messaging protocol.
  caelestiafoxHost = pkgs.writeShellApplication {
    name = "caelestiafox";
    runtimeInputs = [ pkgs.inotify-tools ];
    text = builtins.readFile ./native-host.sh;
  };

  # Registers that script as a native messaging host Firefox can find.
  caelestiafoxManifest = pkgs.runCommand "caelestiafox-native-host" { } ''
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    cat > $out/lib/mozilla/native-messaging-hosts/caelestiafox.json <<JSON
    {
      "name": "caelestiafox",
      "description": "Native app for CaelestiaFox extension.",
      "path": "${caelestiafoxHost}/bin/caelestiafox",
      "type": "stdio",
      "allowed_extensions": ["caelestiafox@caelestia.org"]
    }
    JSON
  '';

  # The extension itself is already signed and published on AMO, so it's
  # fetched directly rather than built/signed by hand.
  caelestiafoxAddon = pkgs.stdenvNoCC.mkDerivation {
    pname = "caelestiafox";
    version = "2.0";
    src = pkgs.fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/latest/caelestiafox/latest.xpi";
      sha256 = "sha256-PlRWZbkeDIaj5s0FO+QSwqD5NtdSSvXVZ27C+/b8Wxc="; # first `home-manager switch` will fail and print the real hash
    };
    dontUnpack = true;
    installPhase = ''
      dir=$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
      mkdir -p "$dir"
      cp "$src" "$dir/caelestiafox@caelestia.org.xpi"
    '';
  };
in
{
	imports = [
		inputs.caelestia-shell.homeManagerModules.default
	];

	home.username = "marco";
	home.homeDirectory = "/home/marco";
	home.stateVersion = "26.05";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [ 
		cliphist
		hyprpicker
		yazi
		fuzzel
		nsxiv
		fastfetch
		jq
		wget
		downloadWallpapers
	];

	# Newsboat
	programs.newsboat = {
		enable = true;
		autoReload = true;
		browser = "librewolf";
		extraConfig = ''
			bind-key j down
			bind-key k up
			bind-key j next articlelist
			bind-key k prev articlelist
			bind-key J next-feed articlelist
			bind-key K prev-feed articlelist
			bind-key G end
			bind-key g home
			bind-key d pagedown
			bind-key u pageup
			bind-key l open
			bind-key h quit
			bind-key a toggle-article-read
			bind-key n next-unread
			bind-key N prev-unread
			bind-key D pb-download
			bind-key U show-urls
			bind-key x pb-delete

			macro , set browser "mpv %u --really-quiet --no-terminal" ;open-in-browser
		'';
	};
	xdg.configFile."newsboat/urls".source = ./newsboat-urls;

	# Mpv
	programs.mpv = {
		enable = true;
		package = (
			pkgs.mpv.override {
				scripts = with pkgs.mpvScripts; [
					sponsorblock
				];

				mpv-unwrapped = pkgs.mpv-unwrapped.override {
					waylandSupport = true;
				};
			}
		);
	};

	# Zathura
	programs.zathura = {
		enable = true;
		options = {
			selection-clipboard = "clipboard";
		};
	};

	# Profile Picture
	home.file.".face" = {
		source = ./.face;
	};

	# Vesktop (Discord alternative)
	programs.vesktop = {
		enable = true;
		settings = {
			discordBranch = "stable";
			tray = true;
			minimizeToTray = false;
			arRPC = false;
		};
	};

	# Btop
	programs.btop = {
		enable = true;
		settings = {
			color_theme = "caelestia";
			theme_background = false;
			vim_keys = true;
		};
	};

	# Librewolf
	programs.librewolf = {
		enable = true;
		nativeMessagingHosts = [ caelestiafoxManifest ];
		policies = {
			# Extensions
			ExtensionSettings = let
				amo = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
			in
			{
				# Bitwarden Password Manager
				"{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
					install_url = amo "bitwarden-password-manager";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# CaelestiaFox
				"caelestiafox@caelestia.org" = {
					install_url = amo "caelestiafox";
					installation_mode = "normal_installed";
				};
				# Indie Wiki Buddy
				"{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = {
					install_url = amo "indie-wiki-buddy";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# Knockoff - Amazon Brand Filter
				"knockoff@knockoff.shopping" = {
					install_url = amo "knockoff-amazon-brand-filter";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# Librezam
				"Librezam@Librezam" = {
					install_url = amo "librezam";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# SponsorBlock
				"sponsorBlocker@ajay.app" = {
					install_url = amo "sponsorblock";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# Theater Mode for YouTube
				"{b8326f03-322f-4112-96bd-e7996548d99f}" = {
					install_url = amo "theater-mode-for-youtube";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# Unhook
				"myallychou@gmail.com" = {
					install_url = amo "youtube-recommended-videos";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};
				# YouTube NonStop
				"{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" = {
					install_url = amo "youtube-nonstop";
					installation_mode = "normal_installed";
					default_area = "navbar";
				};

			};
		};

		profiles.default = {
			# UserChrome css
			userChrome = builtins.readFile ./userChrome.css;
			# Browser settings
			settings = {
				"privacy.resistFingerprinting" = false;
				"middlemouse.paste" = false;
				"browser.toolbars.bookmarks.visibility" = "never";
				"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
				"extensions.autoDisableScopes" = 0; # auto-enable the extension below
			};
			# extensions.packages = [ caelestiafoxAddon ];
		};
	};

	# Caelestia
	programs.caelestia = {
		enable = true;
		systemd = {
			enable = true;
			target = "graphical-session.target";
			environment = [];
		};
		settings = {
			bar.statusIcons = [
			{ id = "lockStatus"; enabled = true; }
			{ id = "network"; enabled = true; }
			{ id = "bluetooth"; enabled = true; }
			{ id = "battery"; enabled = true; }
			];
			paths.wallpaperDir = "~/Pictures/Wallpapers";
		};
		cli = {
			enable = true;
			settings = {
				theme.enableGtk = false;
			};
		};
	};

	# Bash
	xdg.enable = true;
	home.sessionVariables = {
		EDITOR = "nvim";
		OPENER = "nvim";
	};
	programs.bash = {
		enable = true;
		historyFile = "${config.xdg.stateHome}/bash/history";
		shellAliases = {
			ls = "ls --color=auto";
			grep = "grep --color=auto";
		};
		initExtra = ''
			set -o vi
			bind -m vi-insert 'Control-l: clear-screen'
			if [ -f ${config.xdg.stateHome}/caelestia/sequences.txt ]; then
				cat ${config.xdg.stateHome}/caelestia/sequences.txt 2> /dev/null
			fi
			PS1='\[\e[91m\][\[\e[93m\]\u\[\e[92m\]@\[\e[96m\]\H\[\e[94m\]:\[\e[95m\]\w\[\e[91m\]]\n\[\e[0m\]\\$ '
			shopt -s checkwinsize
			function y() {
				local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
				command yazi "$@" --cwd-file="$tmp"
				IFS= read -r -d ''' cwd < "$tmp"
				[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
				rm -f -- "$tmp"
			}
			'';
	};

	# Kitty
	programs.kitty = {
		enable = true;
		settings = {
			confirm_os_window_close = 0;
		};
	};

	# Hyprland
	wayland.windowManager.hyprland = {
		enable = true;
		package = null;
		portalPackage = null;
		systemd.enable = false;
		configType = "lua";

		settings = {
			config = {
				general = {
					layout = "master";
				};
				dwindle = {
					preserve_split = true;
					force_split = 2;
				};
				master = {
					new_status = "master";
					new_on_top = true;
				};
				misc = {
					force_default_wallpaper = 1;
					disable_hyprland_logo = true;
					enable_swallow = true;
					swallow_regex = "kitty";
					swallow_exception_regex = "wev";
					middle_click_paste = false;
				};
				input = {
					kb_layout = "us";
					kb_variant = "intl";
					follow_mouse = 1;
					touchpad.natural_scroll = true;
				};
			};
			window_rule = [
			{
				name = "suppress-maximize-events";
				match.class = ".*";
				suppress_event = "maximize";
			}
			];

		};
		extraLuaFiles."bindings" = ./bindings.lua;
	};

	# Git
	programs.git = {
		enable = true;
		settings.user.name = "bonettimrc";
		settings.user.email = "bonetti.mrc@gmail.com";
		settings.core.editor = "nvim";
	};
}
