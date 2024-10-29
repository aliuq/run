#!/bin/sh

BASE_URL=${BASE_URL:-"https://raw.githubusercontent.com/aliuq/run/refs/heads/master"}

if ! command -v run >/dev/null 2>&1; then
  if echo "$BASE_URL" | grep -qE '^https?://'; then
    . /dev/stdin <<EOF
$(curl -sSL $BASE_URL/helper.sh)
EOF
  else
    . $BASE_URL/helper.sh
  fi
fi

## BEGIN

install_zsh_from_ubuntu() {
  zsh_version=$(read_input "请输入 zsh 版本(5.9): " 5.9)
  mirror_url=$(read_confirm_and_input "是否使用 mirror, 结尾不要有斜杠/ (y/n): " "https://dl.llll.host")

  info "zsh version: $(cyan $zsh_version)"
  info "mirror  url: $(cyan $mirror_url)"

  if $dry_run; then run "commands_valid curl tar"; else commands_valid curl tar; fi

  url="https://sourceforge.net/projects/zsh/files/zsh/$zsh_version/zsh-$zsh_version.tar.xz/download"
  info "==> 开始解析: $url"
  download_url=$(curl -s "$url" | grep -oP "(?<=href=\")[^\"]+(?=\")")
  sleep 1
  info "==> 解析后: $download_url"
  real_url="$mirror_url$download_url"
  info "==> 应用代理: $real_url"

  run "apt install -y curl make gcc libncurses5-dev libncursesw5-dev"
  run "curl -fsS -o /tmp/zsh.tar.xz \"$real_url\""
  run "tar -xf /tmp/zsh.tar.xz -C /tmp"
  
  current_dir=$(pwd)
  run "cd /tmp/zsh-$zsh_version && ./Util/preconfig && ./configure --without-tcsetpgrp --prefix=/usr --bindir=/bin && make -j 20 install.bin install.modules install.fns"
  run "cd $current_dir && rm -rf /tmp/zsh.tar.xz && rm -rf /tmp/zsh-$zsh_version"
  run "zsh --version && echo \"/bin/zsh\" | tee -a /etc/shells && echo \"/usr/bin/zsh\" | tee -a /etc/shells"
}

# 安装 zsh
install_zsh() {
  log "安装 zsh"

  # if command_exists zsh; then
  #   yellow "==> zsh 已安装, Skipping...\n"
  #   return
  # fi

  if $force || read_confirm "是否安装 zsh? (y/n): "; then
    params="包管理器:推荐|源码"
    read_from_options_show $params
    install_type=$(read_from_options "请选择安装方式?" "1" $params true)
    if [ $lsb_dist = "ubuntu" ]; then
      case "$install_type" in
        1) run "apt update -y && apt install -y zsh" ;;
        2) install_zsh_from_ubuntu ;;
        *) red "==> 错误选项"; exit 0 ;;
      esac
    fi

    if $dry_run; then run "chsh -s $(which zsh)"; else chsh -s $(which zsh); fi
    info "==> Default Shell: $(cyan $SHELL)"
  fi
}
