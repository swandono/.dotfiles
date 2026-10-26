# NeoVim Config

Make NeoVim better Editor!!!

<img width="2560" alt="image" src="https://github.com/swandono/.dotfiles/assets/2106030/22b0ffcb-a60c-41ad-b6b1-fddc732ad36b">

## Installation

You need to install [fzf](https://github.com/junegunn/fzf), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [lazygit](https://github.com/jesseduffield/lazygit), [gnu-sed](https://www.gnu.org/software/sed/) first before using this config.

After that you can create `nvim` folder in `~/.config`, then git clone this repo!

## Server setup

`setup/install.sh` turns a freshly hardened Ubuntu 24.04 VPS into a box with this shell, editor and toolset. It is plain bash, runs as root only (`EUID` 0, `HOME=/root`), and the `essential` profile works on x86_64 and aarch64 (`full` skips a tool with a warning where upstream has no aarch64 build).

Hardening is done by hand first and is never touched by the installer: the sudo user, sshd, UFW, fail2ban, the ufw-docker rules and the locale. The installer starts no containers and changes nothing about SSH or the firewall.

### Install

```sh
git clone https://github.com/swandono/.dotfiles.git ~/.config/nvim
~/.config/nvim/setup/install.sh
```

With no arguments on a terminal it opens a menu: Essential, Full or Custom. Each preset pre-ticks an editable checklist of steps, dependencies between steps are added for you, and a tool-choice screen is shown for every group that has a selected step (`whiptail` if present, plain prompts otherwise). For scripted runs:

```sh
setup/install.sh essential|full [--choose k=v,...] [--only a,b] [--skip a,b] [--list] [--dry-run]
```

`--dry-run` prints the resolved step list without installing. Re-running is safe and changes nothing unless `setup/versions.env` changed. `essential` aborts on the first failure; `full` continues past a failed step, prints a summary, and exits non-zero if any step failed.

### Profiles

- **essential**: base packages, container engine, Tailscale (installed, not logged in), zsh with oh-my-zsh, the prompt and plugins, Neovim with this config (plus Node LTS, so Mason can install npm-based servers), the terminal multiplexer, and the CLI basics (git TUI, fzf, ripgrep, fd, zoxide, `ls` replacement).
- **full**: essential plus more CLI tools (bat, btop/htop, ncdu, direnv, yazi, gh, ...), language runtimes through mise (Node, Python, Go, Java, bun, pnpm, uv), Rust with common cargo tools, Java tooling (jdtls, java-debug), cloud and ops tools, network and security packages, a headless-capable Chrome, and the AI/agent CLIs.

### Tool choices

| Choice | Values | Default |
|---|---|---|
| `container` | `docker`, `podman`, `none` | `docker` |
| `mux` | `tmux`, `zellij`, `none` | `tmux` |
| `prompt` | `p10k`, `starship` | `p10k` |
| `git_tui` | `lazygit`, `gitui`, `both` | `lazygit` |
| `ls` | `eza`, `ls` | `eza` |
| `monitor` | `btop`, `htop`, `both` | `both` |
| `ai` | any of `claude`, `codex`, `opencode`, `gemini`, `copilot` (join with `+`) | all five |

Example: `--choose container=podman,mux=zellij,ai=claude+codex`. Choices come from the menu or `--choose`, then the previous run's saved choices, then the defaults. They are remembered in `/var/lib/dotfiles-bootstrap/choices` (and `~/.config/dotfiles-bootstrap/choices.zsh` for the shell, not in the repo). Switching a choice later installs the new tool and leaves the old one installed, with a warning naming it.

### Machine-local files (never in the repo)

- `~/.zshrc.local`: created with a comment header if missing, never overwritten, sourced last by the zshrc. Put private aliases here, plus `AWV_DEFAULT_PROFILE` / `AWV_DEFAULT_DURATION` for the `awv` helper and `CLHERE_PROFILE` for `clhere`.
- `~/.config/tmux/local.conf`: per-machine tmux settings.

### After the install

- Run `tailscale up` by hand (it needs an interactive login), then log out and back in.
- Podman users: the ufw-docker rules are Docker-specific and do not apply to Podman.
- `~/.config/yazi` is a symlink into this repo, so `ya pkg add` writes into the repo.
- `nvim` installs plugins from `lazy-lock.json` and LSPs on first start. A warning about `lazy-lock.json` drift may appear during the install until the lock is regenerated.

### Pins

Every pinned version and plugin commit lives in `setup/versions.env`. To bump one, edit the line and re-run `setup/install.sh`; the step reinstalls only what changed. AI/agent CLIs are not pinned (they install the latest and self-update). After bumping `YAZI_VERSION`, repeat the manual check described next to it in that file (start yazi in a tmux pane and read the pane), because loading the flavor cannot be verified automatically.

### Testing

`setup/test.sh` runs the installer in throwaway `ubuntu:24.04` containers (never on the host):

- `lint`: shellcheck on everything under `setup/`.
- `lib`: unit tests of the helper libraries.
- `essential [--snapshot]`: essential twice (the second run must report no changes), then smoke checks. `--snapshot` keeps the result as an image that `full` builds on.
- `full [--only a,b] [--skip a,b]`: the full profile on that snapshot, twice, then all smoke checks. Use `--skip ollama` to avoid the large download.
- `clean`: removes every test container and image.

A disk guard refuses to start when Docker's root has less than 8 GB free (essential) or 15 GB (full).
