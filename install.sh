#!/bin/zsh

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
cd "$PWD"

# VSCode settings
if [[ `uname` =~ "Darwin" ]]; then
  CODE_PATH=~/Library/Application\ Support/Code/User
else
  CODE_PATH=~/.config/Code/User
  [ ! -e $CODE_PATH ] && CODE_PATH=~/.vscode-server/data/Machine
fi
mkdir -p "$CODE_PATH"

for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup $target
  symlink "$PWD/$name" $target
done

# SSH config (macOS only)
if [[ `uname` =~ "Darwin" ]]; then
  target=~/.ssh/config
  backup $target
  symlink "$PWD/config" $target
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
fi

# exec zsh
echo "👌 Dotfiles setup complete!"

