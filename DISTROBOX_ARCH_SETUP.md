# Distrobox Arch Linux Zsh Setup Guide

This guide details how to set up this modular, performance-optimized Zsh configuration within an Arch Linux Distrobox container.

## 1. Create and Enter the Distrobox
Initialize a new container using the official Arch Linux image:

```bash
distrobox create -n arch-dev -i archlinux:latest
distrobox enter arch-dev
```

## 2. Install Core Dependencies
Update the system and install the required CLI tools and plugins:

```bash
# Update system
sudo pacman -Syu

# Install core tools & utilities
sudo pacman -S --needed \
    zsh \
    fzf \
    zoxide \
    neovim \
    yazi \
    eza \
    bat \
    git-delta \
    fd \
    ripgrep \
    lazygit \
    trash-cli \
    wl-clipboard \
    zathura

# Install Zsh plugins available in official Arch repos
sudo pacman -S --needed \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-theme-powerlevel10k
```

## 3. Install AUR Dependencies (fzf-tab)
Install `fzf-tab-git` using an AUR helper such as `paru` or `yay`:

```bash
# If you use paru:
paru -S fzf-tab-git

# Or if you use yay:
yay -S fzf-tab-git
```

## 4. Configure Shell Entry
To ensure the container starts with Zsh and loads this configuration:

### Option A: Set Zsh as default shell
```bash
sudo chsh -s /usr/bin/zsh $USER
```

### Option B: Export ZDOTDIR
Ensure your `~/.zshenv` sets:
```bash
export ZDOTDIR="$HOME/.config/zsh"
```

## 5. Initialization & Caching
The first time you start Zsh, it will automatically:
- **Generate Caches**: Creates tool caches in `~/.cache/zsh/tools/` for `fzf` and `zoxide`.
- **Compile Bytecode**: Compiles your config files into `.zwc` bytecode in the background via `zsh-defer`.
- **Instant Prompt**: Powerlevel10k will generate its instant prompt cache.

## Troubleshooting & Tips
- **Nerd Fonts**: Ensure your terminal emulator is configured with a [Nerd Font](https://www.nerdfonts.com/) for prompt icons and directory glyphs.
- **Update Cache**: If you update tools or change paths, regenerate bytecode using:
  ```bash
  zsh-update-cache
  ```
