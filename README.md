# Chezmoi Dotfiles

This repository contains my personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### Install chezmoi

```bash
# Install chezmoi to local bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
```

### Initialize from this repository

```bash
# Initialize chezmoi with this repository and apply
chezmoi init --apply gartmeier
```

## Usage

### Add new dotfiles

```bash
# Add a file to be managed by chezmoi
chezmoi add ~/.zshrc
chezmoi add ~/.config/kitty/kitty.conf
```

### Update dotfiles

```bash
# Edit a managed file
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply
```

### Sync changes

```bash
# Check what would change
chezmoi diff

# Apply changes
chezmoi apply

# Commit and push changes
chezmoi cd
git add .
git commit -m "Update dotfiles"
git push
```

### View status

```bash
# Check current status
chezmoi status

# Show differences
chezmoi diff
```

## Current Configuration

This setup includes:

- **Zsh configuration** (`.zshrc`)
- **Kitty terminal configuration** with multiple themes:
  - Catppuccin (Frappe, Latte, Mocha)
  - Tokyo Night
- **Local binaries** in `~/.local/bin/`

## Useful Commands

- `chezmoi apply` - Apply changes to your system
- `chezmoi diff` - Show what would change
- `chezmoi status` - Show status of managed files
- `chezmoi edit <file>` - Edit a managed file
- `chezmoi cd` - Navigate to the chezmoi source directory