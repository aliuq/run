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

install_zsh_from_ubuntu() {
  local zsh_version=$(read_input "请输入 zsh 版本(5.9): " 5.9)
  # local mirror_url=$(read_confirm_and_input "是否使用 mirror, 结尾要有斜杠/ (y/n): " "https://dl.llll.host/")

  info "==> zsh version: $(cyan $zsh_version)"
  # info "== mirror  url: $(cyan $mirror_url)"

  if $dry_run; then run "commands_valid curl tar"; else commands_valid curl tar; fi

  local url="https://sourceforge.net/projects/zsh/files/zsh/$zsh_version/zsh-$zsh_version.tar.xz/download"
  echo "==> 开始解析: $url"
  local download_url=$(curl -s "$url" | grep -oP "(?<=href=\")[^\"]+(?=\")")
  echo "==> 解析后: $download_url"
  sleep 1
  download_url=$(curl -s "$download_url" | grep -oP "(?<=href=\")[^\"]+(?=\")")
  echo "==> 解析后: $download_url"
  sleep 1
  local real_url="$download_url"
  # local real_url="$mirror_url$download_url"
  echo "==> 应用代理: $real_url"

  run "apt install -y curl make gcc libncurses5-dev libncursesw5-dev"
  run "curl -fsS -o /tmp/zsh.tar.xz \"$real_url\""
  run "tar -xf /tmp/zsh.tar.xz -C /tmp"

  local current_dir=$(pwd)
  run "cd /tmp/zsh-$zsh_version && ./Util/preconfig && ./configure --without-tcsetpgrp --prefix=/usr --bindir=/bin && make -j 20 install.bin install.modules install.fns"
  run "cd $current_dir && rm -rf /tmp/zsh.tar.xz && rm -rf /tmp/zsh-$zsh_version"
  run "zsh --version && echo \"/bin/zsh\" | tee -a /etc/shells && echo \"/usr/bin/zsh\" | tee -a /etc/shells"
}

# 安装 zsh
install_zsh() {
  log "安装 zsh"

  if command_exists zsh; then
    yellow "==> zsh 已安装, Skipping...\n"
    return
  fi

  if $force || read_confirm "是否安装 zsh? (y/n): "; then
    params="包管理器:推荐|源码"
    read_from_options_show $params
    install_type=$(read_from_options "请选择安装方式?" "1" $params true)
    if [ $lsb_dist = "ubuntu" ]; then
      case "$install_type" in
      1) run "apt update -y && apt install -y zsh" ;;
      2) install_zsh_from_ubuntu ;;
      *)
        red "==> 错误选项"
        exit 0
        ;;
      esac
    fi

    if $dry_run; then run "chsh -s $(which zsh)"; else chsh -s $(which zsh); fi
    green "==> Default Shell: $(cyan $SHELL)"
  fi
}

install_deps() {
  log "安装依赖 (eza, fzf, zoxide)"
  # 安装 eza
  if ! command_exists eza; then
    run "curl -sL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz"
    run "chmod +x eza && chown root:root eza && mv eza /usr/local/bin/eza"
    green "==> eza 安装成功"
  else
    info "✔ eza 已安装"
  fi

  # 安装 fzf
  if ! command_exists fzf; then
    run "apt update -y && apt install -y fzf"
    green "==> fzf 安装成功"
  else
    info "✔ fzf 已安装"
  fi

  # 安装 zoxide
  if ! command_exists zoxide; then
    local zoxide_url="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
    run "curl -sSfL $zoxide_url | sh -s -- --bin-dir /usr/local/bin"
    green "==> zoxide 安装成功"
  else
    info "✔ zoxide 已安装"
  fi

  # 安装 starship
  if ! command_exists starship; then
    local starship_url="https://starship.rs/install.sh"
    if $dry_run; then run "curl -sS $starship_url | sh -s -- -y"; else curl -sS $starship_url | sh -s -- -y; fi
    green "==> starship 安装成功"
  else
    info "✔ starship 已安装"
  fi

  run "mkdir -p ~/.config"
  if [ ! -f ~/.config/starship.toml ]; then
    run "curl -fsSL $GITHUB_RAW_URL/aliuq/run/master/files/starship.toml >~/.config/starship.toml"
    info "✔ starship 配置文件已生成"
  fi
}

# 安装 zimfw
install_zimfw() {
  log "安装 zimfw"

  install_deps

  if [ -d "$HOME/.zim" ]; then
    yellow "==> zimfw 已安装, Skipping...\n"
    return
  fi

  if $is_remote; then
    run "curl -sL \"$BASE_URL/feat/zimfw-install.sh\" | zsh"
  else
    run "zsh \"$BASE_URL/feat/zimfw-install.sh\""
  fi

  if [ $lsb_dist = "ubuntu" ]; then
    [ ! -f ~/.zshenv ] && run "touch ~/.zshenv"
    run "echo \"skip_global_compinit=1\" >> ~/.zshenv"
    info "✔ zshenv 配置已生成"
  fi
}

# sh <(curl -sL https://raw.githubusercontent.com/aliuq/run/refs/heads/master/test/start.sh)
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/run.sh)
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/run/refs/heads/master/mods/config.sh)
