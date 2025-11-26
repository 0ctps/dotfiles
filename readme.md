# 💻 dotfiles 💨💨

Installation
-------------------

```bash
$ git clone [https://github.com/0ctps/dotfiles](https://github.com/0ctps/dotfiles)
$ cd dotfiles

# Initialize environment (Install packages & Setup SSH)
$ ./dots init

# Install dotfiles (Create symlinks)
$ ./dots install --vim --zsh --tmux
$ ./dots install zsh vim
$ ./dots -i --all

# Uninstall dotfiles (Remove symlinks)
$ ./dots remove all
$ ./dots -r tmux
```

## Usage

```bash
./dots [COMMAND] [OPTIONS] [TARGETS...]
```

### Commands

  * `init` (`--init`): Initialize environment (packages & SSH)
  * `install` (`-i`): Install dotfiles (create symlinks) [Default]
  * `remove` (`-r`): Remove dotfiles (delete symlinks)
  * `help` (`-h`): Show help
  * `version` (`-v`): Show version

### Options & Targets

  * `all` (`-a`): Target all supported dotfiles
  * Individual targets: `bash`, `fish`, `ssh`, `tmux`, `vim`, `zsh`

## Supported types

  * bash
  * fish
  * ssh
  * tmux
  * vim
  * zsh
