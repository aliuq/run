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
    local params="包管理器:推荐|源码"
    read_from_options_show $params
    local install_type=$(read_from_options "请选择安装方式?" "1" $params true)
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
    run "curl -fsSL $toml_file > $dest_file"
    log_success "✔ starship 配置文件已生成"
  else
    log_warn "⚠️ starship 配置文件(~/.config/starship.toml)已存在, 如果需要重新生成请手动删除!"
  fi

  log_success "工具安装完成"
}

install_basic_tools() {
  log "安装基础工具 eza fzf zoxide"
  echo
  cyan "eza:    ls 命令的现代替代品"
  cyan "fzf:    通用的模糊搜索工具"
  cyan "zoxide: cd 命令的智能替代品"
  echo

  install_eza
  install_fzf
  install_zoxide

  if command_exists omz; then
    run "omz plugin enable eza fzf zoxide"
  fi

}

# 安装 eza
# https://github.com/eza-community/eza
install_eza() {
  if ! command_exists eza; then
    install_eza_process
  else
    # 对比版本号，格式为 `v0.20.8`
    local version=$(eza --version | grep -oP '\Kv[0-9]+\.[0-9]+\.[0-9]+')
    local url="https://api.github.com/repos/eza-community/eza/releases/latest"
    local new_version=$(curl -s $url | jq -r '.tag_name')
    if [ "$version" != "$new_version" ]; then
      log_warn "⚠️ eza 版本过低: $version, 最新版本: $new_version"
      install_eza_process $new_version
      echo
      log_success "✔ eza 更新成功"
    else
      log_warn "⚠️ eza 已安装, 版本: $version"
    fi
  fi
}

install_eza_process() {
  # 如果不存在 $1 参数，则调用接口取最新版本号，否则，直接使用参数
  local repo="eza-community/eza"
  local url="https://api.github.com/repos/$repo/releases/latest"
  local ver=${1:-$(curl -s "$url" | jq -r '.tag_name')}

  # 下载最新版本的二进制文件到 /tmp 目录
  local d_url="https://github.com/$repo/releases/download"
  local name="eza_x86_64-unknown-linux-gnu.tar.gz"
  local dest="/tmp/$name"
  run "curl -fsSLo $dest $d_url/$ver/$name"

  # 解压缩下载的文件到 /tmp 目录
  run "tar -xzf $dest -C /tmp"

  # 将二进制文件移动到 /usr/local/bin 目录
  run "mv /tmp/eza /usr/local/bin/"

  # 清理下载的文件
  run "rm $dest"

  # 验证安装
  run "eza --version"
}

# 安装 fzf
# https://github.com/junegunn/fzf
install_fzf() {
  if ! command_exists fzf; then
    install_fzf_process
  else
    # 对比版本号，格式为 `v0.20.8`
    local version=$(fzf --version | grep -oP '\K[0-9]+\.[0-9]+\.[0-9]+')
    version="v$version"
    local url="https://api.github.com/repos/junegunn/fzf/releases/latest"
    local new_version=$(curl -s $url | jq -r '.tag_name')
    if [ "$version" != "$new_version" ]; then
      log_warn "⚠️ fzf 版本过低: $version, 最新版本: $new_version"
      install_fzf_process $new_version
      echo
      log_success "✔ fzf 更新成功"
    else
      log_warn "⚠️ fzf 已安装, 版本: $version"
    fi
  fi
}

install_fzf_process() {
  # 如果不存在 $1 参数，则调用接口取最新版本号，否则，直接使用参数
  local repo="junegunn/fzf"
  local url="https://api.github.com/repos/$repo/releases/latest"
  local ver=${1:-$(curl -s "$url" | jq -r '.tag_name')}
  local fmt_ver=$(echo $ver | sed 's/v//')

  # 下载最新版本的二进制文件到 /tmp 目录
  local d_url="https://github.com/$repo/releases/download"
  local name="fzf-$fmt_ver-linux_amd64.tar.gz"
  local dest="/tmp/$name"
  run "curl -fsSLo $dest $d_url/$ver/$name"

  # 解压缩下载的文件到 /tmp 目录
  run "tar -xzf $dest -C /tmp"

  # 将二进制文件移动到 /usr/local/bin 目录
  run "mv /tmp/fzf /usr/local/bin/"

  # 清理下载的文件
  run "rm $dest"

  # 验证安装
  run "fzf --version"
}

# 安装 zoxide
# https://github.com/ajeetdsouza/zoxide
install_zoxide() {
  if ! command_exists fzf; then
    run "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
  else
    local version=$(zoxide --version | grep -oP '\K[0-9]+\.[0-9]+\.[0-9]+')
    version="v$version"
    local url="https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest"
    local new_version=$(curl -s $url | jq -r '.tag_name')
    if [ "$version" != "$new_version" ]; then
      log_warn "⚠️ zoxide 版本过低: $version, 最新版本: $new_version"
      run "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
      echo
      log_success "✔ zoxide 更新成功"
    else
      log_warn "⚠️ zoxide 已安装, 版本: $version"
    fi
  fi
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
    run "sed -i 's/plugins=(git)/plugins=(git starship zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search eza fzf zoxide)/g' ~/.zshrc"
    log_success "✔ oh-my-zsh 插件修改完成"

  fi
}

# 生成 SSH Key
generate_ssh_key() {
  log "生成 SSH Key"

  if $force || read_confirm "是否生成 SSH Key? (y/n): "; then
    local ssh_dir="$HOME/.ssh"
    if [ ! -d "$ssh_dir" ]; then
      run "mkdir -p $ssh_dir"
      run "chmod 700 $ssh_dir"
    fi

    local key_name=$(read_input "请输入密钥名称, 用于明确其作用，不能为空: ")
    [ -z "$key_name" ] && log "$(yellow '密钥名称不能为空, Skipping...')" && return

    local ssh_key="$ssh_dir/$key_name"
    yellow "⚠️ 在没有权限的情况下，判断 $ssh_dir/$key_name 是否存在，可能会出现异常，可手动检查: sudo ls -al $ssh_dir"
    if [ ! -f "$ssh_key" ]; then
      local type=${SSH_KEY_TYPE:-ed25519}
      # 从 git 配置中获取 user.email
      local git_email=$(git config user.email)
      local email=${SSH_KEY_EMAIL:-$git_email}
      local real_email=$(read_input "请输入 email 地址, 默认($email): " $email)

      if [ -z "$real_email" ]; then
        log "$(yellow 'email 为空, Skipping...')"
        log "$(yellow '请先配置 git user.email 或者设置 SSH_KEY_EMAIL 环境变量')"
        info "示例: 推荐使用环境变量设置"
        info "  SSH_KEY_EMAIL=\"<email>\" "
        info "  git config --global user.email \"<email>\" "
        return
      fi

      run "ssh-keygen -t $type -b 4096 -C \"$real_email-$(date -I)\" -f $ssh_key -N \"\" -q"
      run "chmod 600 $ssh_key"
      log_success "✔ SSH Key 生成成功"
      echo
      echo "- 公钥: $(cyan $ssh_key.pub)"
      echo "- 私钥: $(cyan $ssh_key)"
      echo
      echo "- 请将公钥添加到远程服务器的 ~/.ssh/authorized_keys 文件中, 执行下面命令获取执行脚本"
      echo
      green "  echo \"echo \\\"\$(sudo cat $ssh_key.pub)\\\" >> ~/.ssh/authorized_keys\""
      echo
    else
      log_warn "⚠️ SSH Key 已存在: $ssh_key"
    fi
  fi
}

# 添加 waketime
add_waketime() {
  log "添加自定义 waketime 配置"

  local wakatime_config="$HOME/.wakatime.cfg"
  if $force || read_confirm "是否添加通用配置到 $wakatime_config? (y/n): "; then
    if [ ! -f "$wakatime_config" ]; then
      local api_url=$(read_input "请输入 wakatime api url: ")
      [ -z "$api_url" ] && log_warn "api url 不能为空, Skipping..." && return
      local api_key=$(read_input "请输入 wakatime api key: ")
      [ -z "$api_key" ] && log_warn "api key 不能为空, Skipping..." && return

      run "touch $wakatime_config"
      run "echo '[settings]' > $wakatime_config"
      run "echo 'api_url = $api_url' >> $wakatime_config"
      run "echo 'api_key = $api_key' >> $wakatime_config"
      log_success "✔ wakatime 配置文件已生成"
    else
      log_warn "⚠️ wakatime 配置文件($wakatime_config)已存在, 如果需要重新生成请手动删除!"
    fi
  fi
}

# 添加 docker 镜像
add_docker_mirror() {
  log "添加 docker 镜像"

  command_valid docker
  if $force || read_confirm "是否添加 docker 镜像? (y/n): "; then
    local mirror_url=$(read_input "请输入 docker 镜像地址: ")
    [ -z "$mirror_url" ] && log_warn "镜像地址不能为空, Skipping..." && return

    local docker_config="/etc/docker/daemon.json"
    local tmp="/tmp/daemon.json"
    if [ ! -f "$docker_config" ]; then
      log_warn "⚠️ $docker_config 不存在"
      run "mkdir -p /etc/docker && touch $docker_config && chmod 644 $docker_config"
      run "echo '{}' > $docker_config"
      log_success "创建配置文件: $docker_config"
    fi
    # 使用 jq 进行修复意外空格或者空行情况
    if ! jq -e '.["registry-mirrors"]' $docker_config >/dev/null 2>&1; then
      run "jq '. + {\"registry-mirrors\": [\"$mirror_url\"]}' $docker_config > $tmp && mv $tmp $docker_config"
      log "添加镜像地址: $mirror_url"
    else
      run "jq '.\"registry-mirrors\" += [\"$mirror_url\"]' $docker_config > $tmp && mv $tmp $docker_config"
      log "更新镜像地址: $mirror_url"
    fi

    log "重启 docker 服务"
    run "systemctl restart docker"
    log_success "✔ docker 服务重启成功"
    log_success "✔ docker 镜像地址添加成功"
  fi
}
