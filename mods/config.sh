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
    if ! $dry_run && read_confirm "zsh 已安装，是否卸载 zsh? (y/n): "; then
      case $lsb_dist in
      ubuntu) run "apt remove -y zsh" ;;
      *) log "$(red "[$lsb_dist] 暂不支持")" ;;
      esac
    else
      log "$(yellow "zsh 已安装, Skipping...")"
      return
    fi
  fi

  if $force || read_confirm "是否安装 zsh? (y/n): "; then
    params="包管理器:推荐|源码"
    read_from_options_show $params
    install_type=$(read_from_options "请选择安装方式?" "1" $params true)
    log "正在安装中，请稍后……"

    case "$lsb_dist" in
    ubuntu)
      case "$install_type" in
      1)
        run "apt update -y && apt install -y zsh"
        ;;
      2) install_zsh_from_ubuntu ;;
      *)
        log "$(red "错误选项: $install_type")"
        exit 0
        ;;
      esac
      ;;
    *)
      log "$(red "[$lsb_dist] 暂不支持")"
      exit 0
      ;;
    esac

    # if $dry_run; then run "chsh -s $(which zsh)"; else sudo chsh -s $(which zsh); fi
    run "sudo chsh -s $(which zsh)"
    if [ "$user" != 'root' ]; then
      echo
      yellow "⚠️ 当前用户为 $user，设置默认终端可能失败，请手动执行以下命令:"
      echo
      cyan "  sudo chsh -s $(which zsh)"
      echo
    fi

    log "$(green "$(which zsh) 安装成功, 请重新打开终端执行后面的命令")"
  fi
}

install_tools() {
  log "准备安装工具"

  # 安装 eza
  if ! command_exists eza; then
    run "curl -sL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz"
    run "chmod +x eza && chown root:root eza && mv eza /usr/local/bin/eza"
    log_success "✔ eza 安装成功"
  else
    log_warn "⚠️ eza 已安装"
  fi

  # 安装 fzf
  if ! command_exists fzf; then
    run "apt update -y && apt install -y fzf"
    log_success "✔ fzf 安装成功"
  else
    log_warn "⚠️ fzf 已安装"
  fi

  # 安装 zoxide
  if ! command_exists zoxide; then
    local zoxide_url="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
    run "curl -sSfL $zoxide_url | sh -s -- --bin-dir /usr/local/bin"
    log_success "✔ zoxide 安装成功"
  else
    log_warn "⚠️ zoxide 已安装"
  fi

  # 安装 starship
  if ! command_exists starship; then
    local starship_url="https://starship.rs/install.sh"
    run "curl -sS $starship_url | sh -s -- -y"
    log_success "✔ starship 安装成功"
  else
    log_warn "⚠️ starship 已安装"
  fi

  # starship 配置文件
  run "mkdir -p ~/.config"
  if [ ! -f ~/.config/starship.toml ]; then
    local toml_file="$BASE_URL/files/starship.toml"
    local dest_file="~/.config/starship.toml"
    if $is_remote; then
      run "curl -fsSL $toml_file > $dest_file"
    else
      run "cp $toml_file $dest_file"
    fi
    log_success "✔ starship 配置文件已生成"
  else
    log_warn "⚠️ starship 配置文件(~/.config/starship.toml)已存在, 如果需要重新生成请手动删除!"
  fi

  log_success "工具安装完成"
}

# 安装 oh-my-zsh
# Source: https://github.com/ohmyzsh/ohmyzsh
install_ohmyzsh() {
  log "安装 oh-my-zsh"

  if $force || read_confirm "是否安装 oh-my-zsh? (y/n): "; then
    if $dry_run; then run "commands_valid curl git"; else commands_valid curl git; fi

    local ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    local onmyzsh_url="https://install.ohmyz.sh"
    run "curl -fsSL $onmyzsh_url | sh -s - -y"
    log_success "✔ oh-my-zsh 安装成功"

    # zsh-users 社区插件，其中有几个常用的插件，值得推荐
    local zsh_users_org="$GITHUB_URL/zsh-users"
    # 1. https://github.com/zsh-users/zsh-autosuggestions
    local repo_1="zsh-autosuggestions"
    if [ ! -d "$ZSH_CUSTOM/plugins/$repo_1" ]; then
      run "git clone $zsh_users_org/$repo_1.git $ZSH_CUSTOM/plugins/$repo_1"
      log_success "✔ $repo_1 添加成功"
    else
      log_warn "⚠️ $repo_1 已存在 $ZSH_CUSTOM/plugins/$repo_1"
    fi

    # 2. https://github.com/zsh-users/zsh-syntax-highlighting
    local repo_2="zsh-syntax-highlighting"
    if [ ! -d "$ZSH_CUSTOM/plugins/$repo_2" ]; then
      run "git clone $zsh_users_org/$repo_2.git $ZSH_CUSTOM/plugins/$repo_2"
      log_success "✔ $repo_2 添加成功"
    else
      log_warn "⚠️ $repo_2 已存在 $ZSH_CUSTOM/plugins/$repo_2"
    fi

    # 3. https://github.com/zsh-users/zsh-completions
    local repo_3="zsh-completions"
    if [ ! -d "$ZSH_CUSTOM/plugins/$repo_3" ]; then
      run "git clone $zsh_users_org/$repo_3.git $ZSH_CUSTOM/plugins/$repo_3"
      log_success "✔ $repo_3 添加成功"
    else
      log_warn "⚠️ $repo_3 已存在 $ZSH_CUSTOM/plugins/$repo_3"
    fi

    # 4. https://github.com/zsh-users/zsh-history-substring-search
    local repo_4="zsh-history-substring-search"
    if [ ! -d "$ZSH_CUSTOM/plugins/$repo_4" ]; then
      run "git clone $zsh_users_org/$repo_4.git $ZSH_CUSTOM/plugins/$repo_4"
      log_success "✔ $repo_4 添加成功"
    else
      log_warn "⚠️ $repo_4 已存在 $ZSH_CUSTOM/plugins/$repo_4"
    fi

    log_success "✔ oh-my-zsh 插件安装完成"

    # 修改主题为 agnoster
    run "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"agnoster\"/g' ~/.zshrc"
    log_success "✔ oh-my-zsh 主题修改完成 (agnoster)"

    # 修改插件
    run "sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)/g' ~/.zshrc"
    log_success "✔ oh-my-zsh 插件修改完成"
  fi
}

# sh <(curl -sL https://raw.githubusercontent.com/aliuq/run/refs/heads/master/test/start.sh)
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/run.sh)
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/run/refs/heads/master/mods/config.sh)
