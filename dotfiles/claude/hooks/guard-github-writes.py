"""Claude Code PreToolUse hook (Bash): block GitHub writes outside my repositories.

A write is allowed only when it targets a repository owned by one of ALLOWED_OWNERS,
or a fork of one of those under the bot account. Pushes, commits, PRs, issues,
comments, releases and mutating API calls aimed anywhere else are denied, and so is
anything whose target this hook cannot resolve. Denials exit with code 2, which
blocks the tool call and shows the reason to Claude.
"""

import json
import os
import re
import shlex
import subprocess
import sys

ALLOWED_OWNERS = {"trueberryless"}
BOT = "trueberryless-bot"

# Cheap prefilter so ordinary commands never pay for parsing or subprocesses
RISKY_RE = re.compile(r"\b(push|commit|gh)\b|github\.com")
GITHUB_URL_RE = re.compile(r"github\.com[/:]+([^/\s:]+)/([^/\s?#]+)", re.IGNORECASE)
GITHUB_URL_TOKEN_RE = re.compile(r"^(https?://)?(www\.)?github\.com/[^/\s]+/[^/\s]+", re.IGNORECASE)
GITHUB_API_RE = re.compile(r"(api|uploads)\.github\.com", re.IGNORECASE)
API_REPO_PATH_RE = re.compile(r"^/?repos/([^/]+)/([^/?#]+)")
OWNER_REPO_RE = re.compile(r"^[\w.-]+/[\w.-]+$")
ENV_ASSIGNMENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
OPERATOR_CHARS = set(";&|()")

# Commands whose `-c` argument is another shell command line
SHELLS = {"bash", "dev-node", "dev-node24", "sh", "zsh"}
WRAPPERS = {"command", "env", "exec", "nohup", "sudo", "time", "xargs"}

GH_WRITE_ACTIONS = {
    "cache": {"delete"},
    "issue": {"close", "comment", "create", "delete", "develop", "edit", "lock", "pin", "reopen", "transfer", "unlock", "unpin"},
    "label": {"clone", "create", "delete", "edit"},
    "pr": {"close", "comment", "create", "edit", "lock", "merge", "ready", "reopen", "revert", "review", "unlock", "update-branch"},
    "release": {"create", "delete", "delete-asset", "edit", "upload"},
    "repo": {"archive", "autolink", "create", "delete", "deploy-key", "edit", "fork", "rename", "sync", "unarchive"},
    "run": {"cancel", "delete", "rerun"},
    "secret": {"delete", "set"},
    "variable": {"delete", "set"},
    "workflow": {"disable", "enable", "run"},
}
# `gh repo` actions whose first positional argument is the target repository
GH_REPO_POSITIONAL_ACTIONS = {"archive", "create", "delete", "edit", "fork", "sync", "unarchive"}
GH_FLAGS_WITH_VALUE = {"-R", "--repo"}
GH_API_FIELD_FLAGS = {"-F", "-f", "--field", "--input", "--raw-field"}
GH_API_VALUE_FLAGS = {"-H", "-p", "-q", "-t", "--cache", "--header", "--hostname", "--jq", "--preview", "--template"}
GIT_PUSH_VALUE_FLAGS = {"-o", "--exec", "--push-option", "--receive-pack", "--repo"}
CURL_DATA_FLAGS = {"-d", "-F", "-T", "--data", "--data-binary", "--data-raw", "--data-urlencode", "--form", "--json", "--upload-file"}
WGET_DATA_FLAGS = {"--body-data", "--body-file", "--post-data", "--post-file"}


class Denied(Exception):
    pass


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")
    if not RISKY_RE.search(command):
        return 0

    try:
        check_command_line(command, data.get("cwd") or os.getcwd())
    except Denied as error:
        return deny(str(error))
    except Exception as error:
        return deny(f"Could not verify this command ({error!r}), so it is blocked to be safe.")

    return 0


def deny(reason):
    owners = ", ".join(f"`{owner}/...`" for owner in sorted(ALLOWED_OWNERS))
    print(
        f"Blocked by guard-github-writes: {reason}\n"
        f"Claude must never push, commit or post to GitHub repositories outside {owners}. "
        "Leave the changes uncommitted and give the user the exact `git add`, `git commit` "
        "and `git push` commands (or the `gh` command) to run themselves, under their own name.",
        file=sys.stderr,
    )
    return 2


def check_command_line(command, cwd):
    for argv in split_command_line(command):
        cwd = check_argv(argv, cwd)


def split_command_line(command):
    """Split a shell command line into argv lists at `;`, `&&`, `||`, `|`, `&` and parentheses."""
    lexer = shlex.shlex(command.replace("\n", " ; "), posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    # A `#` inside a word (issue refs, URL fragments) must not swallow the rest of the line
    lexer.commenters = ""
    argv = []
    for token in lexer:
        if token and set(token) <= OPERATOR_CHARS:
            if argv:
                yield argv
            argv = []
        else:
            argv.append(token)
    if argv:
        yield argv


def check_argv(argv, cwd):
    """Check one simple command and return the working directory for the next one."""
    argv = strip_wrappers(argv)
    if not argv:
        return cwd

    name = os.path.basename(argv[0])
    args = argv[1:]
    if name in ("cd", "pushd"):
        return resolve_path(cwd, args[0] if args else "~")
    if name in SHELLS and "-c" in args[:-1]:
        check_command_line(args[args.index("-c") + 1], cwd)
    elif name == "nix" and ("-c" in args or "--command" in args):
        flag = "-c" if "-c" in args else "--command"
        check_argv(args[args.index(flag) + 1:], cwd)
    elif name == "eval":
        check_command_line(" ".join(args), cwd)
    elif name == "git":
        check_git(args, cwd)
    elif name == "gh":
        check_gh(args, cwd)
    elif name == "jj":
        check_jj(args, cwd)
    elif name in ("curl", "wget"):
        check_http(name, args)

    return cwd


def strip_wrappers(argv):
    argv = list(argv)
    while argv and (ENV_ASSIGNMENT_RE.match(argv[0]) or os.path.basename(argv[0]) in WRAPPERS):
        argv.pop(0)
        while argv and argv[0].startswith("-"):
            argv.pop(0)
    return argv


def check_git(args, cwd):
    index = 0
    while index < len(args) and args[index].startswith("-"):
        flag = args[index]
        if flag == "-C" and index + 1 < len(args):
            cwd = resolve_path(cwd, args[index + 1])
            index += 2
        elif flag in ("-c", "--config-env", "--git-dir", "--namespace", "--work-tree"):
            index += 2
        else:
            index += 1
    if index >= len(args):
        return

    subcommand = args[index]
    if subcommand == "push":
        check_git_push(args[index + 1:], cwd)
    elif subcommand in ("commit", "merge", "rebase", "cherry-pick", "revert", "am"):
        # Commits made here would carry the bot's name into someone else's repository
        for url in get_git_remote_urls(get_git_default_remote(cwd), cwd, required=False):
            validate_url(url, f"`git {subcommand}` in a clone of `{url}`")


def check_git_push(args, cwd):
    positional = []
    repo_flag = None
    index = 0
    while index < len(args):
        arg = args[index]
        if arg in GIT_PUSH_VALUE_FLAGS:
            if arg == "--repo" and index + 1 < len(args):
                repo_flag = args[index + 1]
            index += 2
            continue
        if arg.startswith("--repo="):
            repo_flag = arg.split("=", 1)[1]
        elif not arg.startswith("-"):
            positional.append(arg)
        index += 1

    remote = repo_flag or (positional[0] if positional else get_git_default_remote(cwd))
    for url in get_git_remote_urls(remote, cwd, required=True):
        validate_url(url, f"`git push` to `{url}`")


def get_git_default_remote(cwd):
    branch = run(["git", "symbolic-ref", "--short", "-q", "HEAD"], cwd)
    for key in (f"branch.{branch}.pushRemote", "remote.pushDefault", f"branch.{branch}.remote"):
        remote = run(["git", "config", "--get", key], cwd)
        if remote:
            return remote
    return "origin"


def get_git_remote_urls(remote, cwd, required):
    if "/" in remote or ":" in remote:
        return [remote]

    urls = run(["git", "remote", "get-url", "--push", "--all", remote], cwd).splitlines()
    if not urls and required:
        raise Denied(f"Cannot resolve the URL of git remote `{remote}` in `{cwd}`.")

    return urls


def check_gh(args, cwd):
    repo_flag = None
    tokens = []
    index = 0
    while index < len(args):
        arg = args[index]
        if arg in GH_FLAGS_WITH_VALUE:
            repo_flag = args[index + 1] if index + 1 < len(args) else ""
            index += 2
            continue
        if arg.startswith("--repo="):
            repo_flag = arg.split("=", 1)[1]
        elif arg.startswith("-R") and len(arg) > 2:
            repo_flag = arg[2:]
        else:
            tokens.append(arg)
        index += 1

    positional = [token for token in tokens if not token.startswith("-")]
    if not positional:
        return
    group = positional[0]
    action = positional[1] if len(positional) > 1 else ""

    if group == "api":
        check_gh_api(tokens[tokens.index("api") + 1:], cwd)
        return
    if action not in GH_WRITE_ACTIONS.get(group, set()):
        return

    what = f"`gh {group} {action}`"
    targets = []
    if group == "repo" and action in GH_REPO_POSITIONAL_ACTIONS and len(positional) > 2:
        targets.append(parse_repo(positional[2]))
    if repo_flag is not None:
        targets.append(parse_repo(repo_flag))
    targets += [parse_repo(token) for token in tokens if GITHUB_URL_TOKEN_RE.match(token)]
    if not targets:
        if group == "repo" and action == "create":
            raise Denied(f"{what} without `OWNER/NAME` would create a repository under `{BOT}`.")
        targets.append(get_current_gh_repo(cwd, what))

    for owner, repo in targets:
        validate_repo(owner, repo, what)


def check_gh_api(args, cwd):
    method = None
    endpoint = None
    fields = []
    index = 0
    while index < len(args):
        arg = args[index]
        value = args[index + 1] if index + 1 < len(args) else ""
        if arg in ("-X", "--method"):
            method = value
            index += 2
            continue
        if arg in GH_API_FIELD_FLAGS:
            fields.append(value)
            index += 2
            continue
        if arg in GH_API_VALUE_FLAGS:
            index += 2
            continue
        if arg.startswith("--method="):
            method = arg.split("=", 1)[1]
        elif arg.startswith("-X") and len(arg) > 2:
            method = arg[2:]
        elif arg.startswith(("--field=", "--raw-field=", "--input=")):
            fields.append(arg.split("=", 1)[1])
        elif arg[:2] in ("-f", "-F") and len(arg) > 2:
            fields.append(arg[2:])
        elif not arg.startswith("-") and endpoint is None:
            endpoint = arg
        index += 1

    method = (method or ("POST" if fields else "GET")).upper()
    if method == "GET" or endpoint is None:
        return

    if endpoint == "graphql":
        if any("mutation" in text for text in [*args, *read_field_files(fields, cwd)]):
            raise Denied("`gh api graphql` mutations cannot be checked against a target repository.")
        return

    path = re.sub(r"^https?://[^/]+", "", endpoint)
    if "{owner}" in path or "{repo}" in path:
        owner, repo = get_current_gh_repo(cwd, f"`gh api {path}`")
        path = path.replace("{owner}", owner).replace("{repo}", repo)
    match = API_REPO_PATH_RE.match(path)
    if not match:
        raise Denied(f"`gh api -X {method} {endpoint}` is not scoped to one of your repositories.")

    validate_repo(match.group(1), match.group(2), f"`gh api -X {method} {path}`")


def read_field_files(fields, cwd):
    contents = []
    for field in fields:
        value = field.split("=", 1)[-1]
        if value.startswith("@"):
            with open(resolve_path(cwd, value[1:])) as file:
                contents.append(file.read())
    return contents


def get_current_gh_repo(cwd, what):
    name = run(["gh", "repo", "set-default", "--view"], cwd)
    if not OWNER_REPO_RE.match(name):
        name = run(["gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"], cwd)
    if not OWNER_REPO_RE.match(name):
        raise Denied(f"Cannot determine which repository {what} would target from `{cwd}`.")

    owner, repo = name.split("/")
    return owner, repo


def check_jj(args, cwd):
    positional = []
    remote = None
    index = 0
    while index < len(args):
        arg = args[index]
        value = args[index + 1] if index + 1 < len(args) else ""
        if arg in ("-R", "--repository"):
            cwd = resolve_path(cwd, value)
            index += 2
            continue
        if arg in ("--remote", "-b", "--bookmark", "-r", "--revisions", "-c", "--change"):
            if arg == "--remote":
                remote = value
            index += 2
            continue
        if arg.startswith("--remote="):
            remote = arg.split("=", 1)[1]
        elif not arg.startswith("-"):
            positional.append(arg)
        index += 1
    if positional[:2] != ["git", "push"]:
        return

    remote = remote or run(["jj", "config", "get", "git.push"], cwd) or "origin"
    remotes = dict(line.split(None, 1) for line in run(["jj", "git", "remote", "list"], cwd).splitlines() if " " in line)
    if remote not in remotes:
        raise Denied(f"Cannot resolve the URL of jj remote `{remote}` in `{cwd}`.")

    validate_url(remotes[remote], f"`jj git push` to `{remotes[remote]}`")


def check_http(name, args):
    urls = [arg for arg in args if GITHUB_API_RE.search(arg)]
    if not urls:
        return

    method = None
    has_body = False
    for index, arg in enumerate(args):
        if arg in ("-X", "--request", "--method") and index + 1 < len(args):
            method = args[index + 1].upper()
        elif arg.startswith(("--request=", "--method=")):
            method = arg.split("=", 1)[1].upper()
        elif arg in (CURL_DATA_FLAGS if name == "curl" else WGET_DATA_FLAGS) or arg.startswith(("--data", "--json=", "--post-", "--body-")):
            has_body = True
    if (method or ("POST" if has_body else "GET")) == "GET":
        return

    for url in urls:
        match = re.search(r"github\.com/repos/([^/]+)/([^/?#\s]+)", url)
        if not match:
            raise Denied(f"`{name}` write request to `{url}` is not scoped to one of your repositories.")
        validate_repo(match.group(1), match.group(2), f"`{name}` write request to `{url}`")


def validate_url(url, what):
    match = GITHUB_URL_RE.search(url)
    # Remotes on other hosts are not GitHub repositories and stay allowed
    if not match:
        return

    validate_repo(match.group(1), match.group(2), what)


def validate_repo(owner, repo, what):
    repo = repo.removesuffix(".git")
    if owner.lower() in ALLOWED_OWNERS:
        return
    if owner.lower() == BOT and repo:
        parent = run(["gh", "api", f"repos/{owner}/{repo}", "--jq", ".parent.owner.login // empty"], None)
        if parent.lower() in ALLOWED_OWNERS:
            return

    raise Denied(f"{what} targets `{owner}/{repo}`, which is not one of your repositories.")


def parse_repo(value):
    match = GITHUB_URL_RE.search(value)
    if match:
        return match.group(1), match.group(2)

    parts = value.strip("/").split("/")
    if len(parts) >= 2:
        return parts[-2], parts[-1]
    return BOT, value


def resolve_path(cwd, path):
    return os.path.normpath(os.path.join(cwd, os.path.expanduser(path)))


def run(command, cwd):
    if cwd is not None and not os.path.isdir(cwd):
        return ""
    if command[0] == "git" and cwd is not None:
        command = ["git", "-C", cwd, *command[1:]]
    try:
        result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=20)
    except (OSError, subprocess.TimeoutExpired):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


if __name__ == "__main__":
    sys.exit(main())
