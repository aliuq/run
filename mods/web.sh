install_fnm() {
  log "安装 fnm"
  tput bold
  echo
  echo "$(cyan fnm) 是一个使用 rust 构建的 Node.js 版本管理工具, 适用于.node-version和.nvmrc文件"
  echo
  echo "Source: $(cyan "https://github.com/Schniz/fnm")"
  tput sgr0

  if $force || read_confirm "是否安装 fnm? (y/n): "; then
    command_exists curl || run "apt update -y && apt install -y curl"
    command_exists unzip || run "apt update -y && apt install -y unzip"

    case $lsb_dist in
    ubuntu)
      run "curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir $HOME/.fnm --skip-shell"
      if ! grep -q "# fnm start" ~/.zshrc; then
        cat <<'EOF' >>~/.zshrc
# fnm start
FNM_PATH="$HOME/.fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env --use-on-cd --shell zsh`"
  eval "`fnm completions --shell zsh`"
fi
EOF
      fi
      ;;
    esac
  fi
}
