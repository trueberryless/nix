{ pkgs, ... }:

let
  git-ucommit = pkgs.writeShellScriptBin "git-ucommit" ''
    args=()
    message=""
    username=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -u|--user)
          username="$2"
          shift 2
          ;;
        -m|--message)
          message="$2"
          shift 2
          ;;
        *)
          args+=("$1")
          shift
          ;;
      esac
    done

    if [[ -n "$username" ]]; then
      user_json=$(${pkgs.gh}/bin/gh api users/"$username")
      name=$(echo "$user_json" | ${pkgs.jq}/bin/jq -r '.name // .login')
      id=$(echo "$user_json" | ${pkgs.jq}/bin/jq -r '.id')

      co_author="Co-authored-by: $name <$id+$username@users.noreply.github.com>"

      if [[ -n "$message" ]]; then
        # Use interpret-trailers on the string directly
        final_msg=$(echo -e "$message" | ${pkgs.git}/bin/git interpret-trailers --trailer "$co_author")
        ${pkgs.git}/bin/git commit "''${args[@]}" -m "$final_msg"
      else
        # If no -m was provided, we let git open the editor with the trailer pre-filled
        ${pkgs.git}/bin/git commit "''${args[@]}" --trailer "$co_author" -e
      fi
    else
      # Fallback to standard commit if no username is provided
      if [[ -n "$message" ]]; then
        ${pkgs.git}/bin/git commit "''${args[@]}" -m "$message"
      else
        ${pkgs.git}/bin/git commit "''${args[@]}"
      fi
    fi
  '';
in
{
  home.packages = [
    pkgs.gh
    pkgs.jq
    git-ucommit
  ];

  home.shellAliases = {
    gcommit = "git-ucommit";
  };
}
