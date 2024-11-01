#!/bin/bash

BASE_URL=${BASE_URL:-"https://raw.githubusercontent.com/aliuq/run/refs/heads/master"}

if echo "$BASE_URL" | grep -qE '^https?://'; then
  is_remote=true
else
  is_remote=false
fi

if ! command -v run >/dev/null 2>&1; then
  if $is_remote; then
    . /dev/stdin <<EOF
$(curl -sSL $BASE_URL/helper.sh)
EOF
  else
    . $BASE_URL/helper.sh
  fi
fi

## BEGIN

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
      run "curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir ~/.fnm --skip-shell"
      run "echo '# fnm' >> ~/.zshrc"
      run "echo 'eval \"\$(fnm completions --shell zsh)\"' >> ~/.zshrc"
      run "echo 'eval \"\$(fnm env --use-on-cd --shell zsh)\"' >> ~/.zshrc"
      # run "echo 'FNM_PATH=\"$HOME/.fnm\"' >> ~/.zshrc"
      # run "echo 'if [ -d \"\$FNM_PATH\" ]; then' >> ~/.zshrc"
      # run "echo '  export PATH=\"\$FNM_PATH:\$PATH\"' >> ~/.zshrc"
      # run "echo '  eval \"\`fnm env\`\"' >> ~/.zshrc"
      # run "echo 'fi' >> ~/.zshrc"
      # run "echo 'eval \"\$(fnm env --use-on-cd --shell zsh)\"' >> ~/.zshrc"
      ;;
    esac
  fi
}
