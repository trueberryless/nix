{ pkgs, lib, username, ... }:
###################################################################################
#
#  Claude Code runs every git and gh command as trueberryless-bot
#
#  The env block lives in Claude Code's managed settings, which the CLI and the
#  desktop app read on every session and which user/project settings cannot
#  override. Your own terminal is untouched.
#
###################################################################################
let
  home = "/Users/${username}";

  botName = "trueberryless-bot";
  botEmail = "324652437+trueberryless-bot@users.noreply.github.com";
  botSigningKey = "${home}/.ssh/github-bot.pub";
  # Classic PAT of the bot account (see README)
  botToken = "${home}/.config/github-bot/token";
  # gh config dir holding only the bot account, generated from botToken below
  botGhConfigDir = "${home}/.config/github-bot/gh";

  # Passed via GIT_CONFIG_{COUNT,KEY_n,VALUE_n}: this is git's highest-priority
  # scope, so it wins over ~/.gitconfig, includeIf blocks and repo-local config
  gitConfig = [
    [ "user.name" botName ]
    [ "user.email" botEmail ]
    [ "user.signingkey" botSigningKey ]
    [ "gpg.format" "ssh" ]
    [ "commit.gpgsign" "true" ]
    [ "tag.gpgsign" "true" ]
    # Drop the keychain helper for GitHub only, then answer with the bot token
    [ "credential.https://github.com.helper" "" ]
    [
      "credential.https://github.com.helper"
      "!f() { test \"$1\" = get && printf 'username=${botName}\\npassword=%s\\n' \"$(cat ${botToken})\"; }; f"
    ]
    # SSH remotes would authenticate with ~/.ssh/github (the human account)
    [ "url.https://github.com/.insteadOf" "git@github.com:" ]
    [ "url.https://github.com/.insteadOf" "ssh://git@github.com/" ]
  ];

  gitEnv =
    { GIT_CONFIG_COUNT = toString (builtins.length gitConfig); }
    // lib.listToAttrs (
      lib.concatLists (
        lib.imap0 (i: kv: [
          (lib.nameValuePair "GIT_CONFIG_KEY_${toString i}" (builtins.elemAt kv 0))
          (lib.nameValuePair "GIT_CONFIG_VALUE_${toString i}" (builtins.elemAt kv 1))
        ]) gitConfig
      )
    );

  managedSettings = pkgs.writeText "claude-code-github-bot.json" (
    builtins.toJSON {
      env = gitEnv // {
        GH_CONFIG_DIR = botGhConfigDir;
        # An inherited token would take precedence over the bot's hosts.yml
        GH_TOKEN = "";
        GITHUB_TOKEN = "";
      };
    }
  );
in
{
  system.activationScripts.postActivation.text = ''
    echo "installing Claude Code managed settings..." >&2
    install -d -m 755 "/Library/Application Support/ClaudeCode/managed-settings.d"
    install -m 644 ${managedSettings} "/Library/Application Support/ClaudeCode/managed-settings.d/50-github-bot.json"
  '';

  home-manager.users.${username} =
    { lib, ... }:
    {
      home.file.".claude/CLAUDE.md".source = ../dotfiles/claude/CLAUDE.md;

      home.activation.claudeBotGh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -r "${botToken}" ]; then
          token="$(tr -d '[:space:]' < "${botToken}")"
          (
            umask 077
            mkdir -p "${botGhConfigDir}"
            printf 'github.com:\n    git_protocol: https\n    users:\n        ${botName}:\n            oauth_token: %s\n    user: ${botName}\n    oauth_token: %s\n' \
              "$token" "$token" > "${botGhConfigDir}/hosts.yml"
          )
        else
          echo "claudeBotGh: ${botToken} missing, Claude Code's gh will not be authenticated" >&2
        fi
      '';
    };
}
