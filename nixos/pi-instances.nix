{ config, pkgs, lib, ... }:

let
  piAdmin = pkgs.writeShellApplication {
    name = "pi-admin";
    runtimeInputs = [ pkgs.shadow pkgs.coreutils ];
    text = ''
      if [ "$#" -ne 2 ]; then
        echo "usage: pi-admin {ensure|remove} <name>" >&2
        exit 2
      fi
      action="$1"
      name="$2"

      if [[ ! "$name" =~ ^[a-z][a-z0-9-]{0,30}$ ]]; then
        echo "pi-admin: invalid name '$name' (must match ^[a-z][a-z0-9-]{0,30}\$)" >&2
        exit 2
      fi

      user="pi-$name"

      case "$action" in
        ensure)
          if id -u "$user" >/dev/null 2>&1; then
            echo "pi-admin: $user already exists" >&2
          else
            useradd -m -g pi -s /run/current-system/sw/bin/bash \
              -c "pi instance $name" "$user"
            chmod 700 "/home/$user"
            echo "pi-admin: created $user" >&2
          fi
          ;;
        remove)
          if id -u "$user" >/dev/null 2>&1; then
            userdel -r "$user"
            echo "pi-admin: removed $user" >&2
          else
            echo "pi-admin: $user does not exist" >&2
          fi
          ;;
        *)
          echo "usage: pi-admin {ensure|remove} <name>" >&2
          exit 2
          ;;
      esac
    '';
  };

  piSpawn = pkgs.writeShellApplication {
    name = "pi-spawn";
    # sudo must be the setuid wrapper (/run/wrappers/bin/sudo), not the plain
    # store binary, so it is called by absolute path and kept out of PATH.
    runtimeInputs = [ ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: pi-spawn <name>" >&2
        exit 2
      fi
      name="$1"
      if [[ ! "$name" =~ ^[a-z][a-z0-9-]{0,30}$ ]]; then
        echo "pi-spawn: invalid name '$name' (must match ^[a-z][a-z0-9-]{0,30}\$)" >&2
        exit 2
      fi

      /run/wrappers/bin/sudo ${piAdmin}/bin/pi-admin ensure "$name"
      echo "pi-spawn: entering pi-$name  (run your tools here; 'exit' to leave)" >&2
      exec /run/wrappers/bin/sudo -iu "pi-$name"
    '';
  };

  piLs = pkgs.writeShellApplication {
    name = "pi-ls";
    runtimeInputs = [ pkgs.gawk ];
    text = ''
      awk -F: '$1 ~ /^pi-/ { print substr($1, 4) }' /etc/passwd
    '';
  };

  piRm = pkgs.writeShellApplication {
    name = "pi-rm";
    runtimeInputs = [ ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: pi-rm <name>" >&2
        exit 2
      fi
      name="$1"
      if [[ ! "$name" =~ ^[a-z][a-z0-9-]{0,30}$ ]]; then
        echo "pi-rm: invalid name '$name' (must match ^[a-z][a-z0-9-]{0,30}\$)" >&2
        exit 2
      fi
      /run/wrappers/bin/sudo ${piAdmin}/bin/pi-admin remove "$name"
    '';
  };
in
{
  users.groups.pi = { };

  # pi itself (from the pi.nix overlay) + the instance-management helpers,
  # available system-wide so every pi-<name> user gets `pi` on PATH.
  environment.systemPackages = [ pkgs.pi-coding-agent piAdmin piSpawn piLs piRm ];

  # Tightly scoped passwordless sudo for ed:
  #   - run the single pi-admin binary as root (create/remove accounts)
  #   - become any user in the "pi" group (the login shell drop-in)
  security.sudo.extraRules = [
    {
      users = [ "ed" ];
      runAs = "root";
      commands = [
        {
          command = "${piAdmin}/bin/pi-admin";
          options = [ "NOPASSWD" ];
        }
      ];
    }
    {
      users = [ "ed" ];
      runAs = "%pi";
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
