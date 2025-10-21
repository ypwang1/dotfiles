#!/bin/zsh
set -e

# Ensure zsh is available
if ! command -v zsh >/dev/null 2>&1; then
  echo "-----> Installing zsh..."
  sudo apt-get update -y && sudo apt-get install -y zsh
fi

backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    else
      rm "$target"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  ln -sf "$file" "$link"
  echo "-----> Symlinked $file -> $link"
}

# Dotfiles
for name in aliases gitconfig irbrc pryrc rspec zprofile zshrc; do
  target="$HOME/.$name"
  backup $target
  symlink "$PWD/$name" $target
done

# Zsh plugins
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"
cd "$ZSH_PLUGINS_DIR"
[ ! -d zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions
[ ! -d zsh-syntax-highlighting ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting
cd "$HOME"

# VSCode settings (only if directory exists)
if [ -d "$HOME/.vscode-server/data/Machine" ]; then
  for name in settings.json keybindings.json; do
    target="$HOME/.vscode-server/data/Machine/$name"
    backup $target
    symlink "$PWD/$name" $target
  done
fi

# SSH config (macOS only)
if [[ `uname` =~ "Darwin" ]]; then
  target=~/.ssh/config
  backup $target
  symlink "$PWD/config" $target
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
fi

# Make sure vscode user uses zsh
if command -v sudo >/dev/null 2>&1; then
  sudo chsh -s $(which zsh) vscode || true
fi

echo "👌 Dotfiles setup complete!"

