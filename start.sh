#!/bin/bash
#
# Last update: 2024-11-17

# Usage:
#
# For shell:
#
# . /dev/stdin <<EOF
# $(curl -sSL https://raw.githubusercontent.com/aliuq/shs/main/helper.sh)
# EOF
#
# . /dev/stdin <<EOF
# $(wget -qO- https://github.com/aliuq/shs/raw/main/helper.sh)
# EOF

# For bash:
#
# source <(curl -sSL https://raw.githubusercontent.com/aliuq/shs/main/helper.sh)
# source <(wget -qO- https://raw.githubusercontent.com/aliuq/shs/main/helper.sh)

verbose=false
force=false
help=false
dry_run=false

remaining_args=""

for arg in "$@"; do
  case "$arg" in
  --verbose | -v) verbose=true ;;
  --verbose=*) verbose="${arg#*=}" ;;
  --force | -[yY]) force=true ;;
  --force=*) force="${arg#*=}" ;;
  --dry-run) dry_run=true ;;
  --dry-run=*) dry_run="${arg#*=}" ;;
  --help | -[hH]) help=true ;;
  *) remaining_args="$remaining_args $arg" ;;
  esac
done

remaining_args=$(echo "$remaining_args" | sed 's/^ *//')
set -- $remaining_args

# =============== Colors ===============
init() { printf "$1$3$2\n"; }

reset() { init "\033[0m" "\033[0m" "$1"; }
bold() { init "\033[1m" "\033[22m" "$1"; }
dim() { init "\033[2m" "\033[22m" "$1"; }
italic() { init "\033[3m" "\033[23m" "$1"; }
underline() { init "\033[4m" "\033[24m" "$1"; }
inverse() { init "\033[7m" "\033[27m" "$1"; }
hidden() { init "\033[8m" "\033[28m" "$1"; }
strikethrough() { init "\033[9m" "\033[29m" "$1"; }

black() { init "\033[30m" "\033[39m" "$1"; }
red() { init "\033[31m" "\033[39m" "$1"; }
green() { init "\033[32m" "\033[39m" "$1"; }
yellow() { init "\033[33m" "\033[39m" "$1"; }
blue() { init "\033[34m" "\033[39m" "$1"; }
magenta() { init "\033[35m" "\033[39m" "$1"; }
cyan() { init "\033[36m" "\033[39m" "$1"; }
white() { init "\033[37m" "\033[39m" "$1"; }
gray() { init "\033[90m" "\033[39m" "$1"; }

bg_black() { init "\033[40m" "\033[49m" "$1"; }
bg_red() { init "\033[41m" "\033[49m" "$1"; }
bg_green() { init "\033[42m" "\033[49m" "$1"; }
bg_yellow() { init "\033[43m" "\033[49m" "$1"; }
bg_blue() { init "\033[44m" "\033[49m" "$1"; }
bg_magenta() { init "\033[45m" "\033[49m" "$1"; }
bg_cyan() { init "\033[46m" "\033[49m" "$1"; }
bg_white() { init "\033[47m" "\033[49m" "$1"; }

black_bright() { init "\033[90m" "\033[39m" "$1"; }
red_bright() { init "\033[91m" "\033[39m" "$1"; }
green_bright() { init "\033[92m" "\033[39m" "$1"; }
yellow_bright() { init "\033[93m" "\033[39m" "$1"; }
blue_bright() { init "\033[94m" "\033[39m" "$1"; }
magenta_bright() { init "\033[95m" "\033[39m" "$1"; }
cyan_bright() { init "\033[96m" "\033[39m" "$1"; }
white_bright() { init "\033[97m" "\033[39m" "$1"; }

bg_black_bright() { init "\033[100m" "\033[49m" "$1"; }
bg_red_bright() { init "\033[101m" "\033[49m" "$1"; }
bg_green_bright() { init "\033[102m" "\033[49m" "$1"; }
bg_yellow_bright() { init "\033[103m" "\033[49m" "$1"; }
bg_blue_bright() { init "\033[104m" "\033[49m" "$1"; }
bg_magenta_bright() { init "\033[105m" "\033[49m" "$1"; }
bg_cyan_bright() { init "\033[106m" "\033[49m" "$1"; }
bg_white_bright() { init "\033[107m" "\033[49m" "$1"; }

print_colors() {
  echo "颜色预览"
  echo
  echo "$(reset reset)  $(bold bold)  $(dim dim)  $(italic italic)  $(underline underline)  $(inverse inverse)  $(hidden hidden)  $(strikethrough strikethrough)"
  echo "$(black black)  $(red red)  $(green green)  $(yellow yellow)  $(blue blue)  $(magenta magenta)  $(cyan cyan)  $(white white)  $(gray gray)"
  echo "$(bg_black white bg_black)  $(bg_red bg_red)  $(bg_green bg_green)  $(bg_yellow bg_yellow)  $(bg_blue bg_blue)  $(bg_magenta bg_magenta)  $(bg_cyan bg_cyan)  $(bg_white bg_white)"
  echo "$(black_bright black_bright)  $(red_bright red_bright)  $(green_bright green_bright)  $(yellow_bright yellow_bright)  $(blue_bright blue_bright)  $(magenta_bright magenta_bright)  $(cyan_bright cyan_bright)  $(white_bright white_bright)"
  echo "$(bg_black_bright bg_black_bright)  $(bg_red_bright bg_red_bright)  $(bg_green_bright bg_green_bright)  $(bg_yellow_bright bg_yellow_bright)  $(bg_blue_bright bg_blue_bright)  $(bg_magenta_bright bg_magenta_bright)  $(bg_cyan_bright bg_cyan_bright)  $(bg_white_bright bg_white_bright)"
  echo
  echo "注意：当背景色和文字颜色共同使用时，在某些终端下，文字样式会一直保持黑色"
  echo
}

# 获取年月日时分秒格式的时间
get_date() {
  date '+%Y年%m月%d日 %H时%M分%S秒'
}

log() {
  t=$(date -u -d '+8 hours' "+%Y-%m-%d %H:%M:%S")
  local type=$2
  local msg="$1"

  case $type in
  warn) msg=$(yellow "$msg") ;;
  error) msg=$(red "$msg") ;;
  success) msg=$(green "$msg") ;;
  *) msg=$msg ;;
  esac

  printf "[INFO] $t $msg\n"
}
debug() {
  t=$(date -u -d '+8 hours' "+%Y-%m-%d %H:%M:%S")
  printf "$(yellow [DEBUG]) $t $1\n"
}
error() {
  t=$(date -u -d '+8 hours' "+%Y-%m-%d %H:%M:%S")
  printf "$(red [ERROR]) $t $(red "$1")\n"
}

log_warn() { log "$1" "warn"; }
log_error() { log "$1" "error"; }
log_success() { log "$1" "success"; }

info() { log "$1"; }

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

command_valid() {
  if ! command_exists "$1"; then
    if [ -z "$2" ]; then
      error "$(bold $1) is not installed or not in PATH"
    else
      error "$2"
    fi
    exit 1
  fi
}

commands_valid() {
  for cmd in "$@"; do
    command_valid "$cmd"
  done
}

run() {
  if $dry_run; then
    echo "+ $sh_c '$1'"
    return
  fi

  if $verbose; then
    echo "+ $sh_c '$1'"
    # echo
    $sh_c "$1"
    # echo
  else
    $sh_c "$1" >/dev/null 2>&1
  fi
}

get_distribution() {
  lsb_dist=""
  # Check for Windows
  case "$(uname -s)" in
  *MINGW* | *MSYS* | *CYGWIN*) lsb_dist="windows" ;;
  esac

  # Check for Linux distribution
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  echo "$lsb_dist"
}

# 发送 Webhook 消息
send_webhook() {
  # 如果不存在 MY_WEBHOOK_URL 环境变量，则不发送消息
  if [ -z "$MY_WEBHOOK_URL" ]; then
    yellow "❕MY_WEBHOOK_URL 环境变量不存在"
    return
  fi

  # 如果不存在消息内容，则不发送消息
  if [ -z "$1" ]; then
    return
  fi

  local content="$1"
  local body="{\"content\":\"$content\"}"
  run "curl -X POST -H 'Content-Type: application/json' -d '$body' \"$MY_WEBHOOK_URL\""
}

read_confirm() {
  echo
  read -p "$(green "$1")" confrim

  case $confrim in
  [yY] | [yY][eE][sS]) return 0 ;;
  [nN] | [nN][oO]) return 1 ;;
  *) return 0 ;;
  esac
}

read_input() {
  read -p "$(green "$1")" input
  case $input in
  "") input="$2" ;;
  esac
  echo $input
}

read_confirm_and_input() {
  read -p "$(green "$1")" confrim
  case $confrim in
  "" | [yY] | [yY][eE][sS]) confrim="$2" ;;
  [nN] | [nN][oO]) confrim="" ;;
  esac
  echo $confrim
}

# $1: 选项列表
read_from_options_show() {
  if [ -n "$1" ]; then
    echo
    IFS="|"
    local index=1
    printf "$(cyan "可选项:") \n"
    echo "-------------------"
    for item in $1; do
      echo "$(green "$index.") $(echo "$item" | sed 's/:/ - /')"
      index=$(($index + 1))
    done
    unset IFS
    echo
  fi
}

# $1: 提示文案
# $2: 默认值
# $3: 选项列表
read_from_options() {
  local option=$(read_input "$1(默认 $2): " "$2")
  local use_index=${4:-false}

  IFS="|"
  local index=1
  for item in $3; do
    if [ "$option" = "$index" ]; then
      IFS=":"
      val=$(echo "$item" | cut -d':' -f1)
      if $use_index; then echo "$index"; else echo "$val"; fi
      break
    fi
    index=$(($index + 1))
  done
  unset IFS
}

# 网络连通性检查
check_network() {
  if ! command_exists curl; then
    red "Error: curl is not installed or not in PATH"
    exit 1
  fi

  local name=${1:-github}
  local limit=${2:-2}
  local timestamp=$(date +%s) # 时间戳

  case "$name" in
  [gG]oogle) url="https://www.google.com/favicon.ico?_=$timestamp" ;;
  [gG]ithub) url="https://github.com/favicon.ico?_=$timestamp" ;;
  [cC]loudflare) url="https://www.cloudflare.com/favicon.ico?_=$timestamp" ;;
  esac

  local start_time=$(date +%s%3N)
  local result=$(curl -s -m 1 -o /dev/null -w "%{http_code}" "$url")
  local end_time=$(date +%s%3N)
  local elapsed_time=$((end_time - start_time))
  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    red "❌ 请求失败"
    return 1
  fi

  if [ $result -eq 200 ]; then
    green "✅ ${elapsed_time}ms"
    return 0
  else
    red "⚠️ 连接失败"
    return 1
  fi
}

get_ip() {
  local ip=$(curl -sL https://ip.llll.host)
  echo $ip
}

set_network() {
  GITHUB_URL=${GITHUB_URL:-"https://github.com"}
  GITHUB_RAW_URL=${GITHUB_RAW_URL:-"https://raw.githubusercontent.com"}
  GITHUB_ASSETS_URL=${GITHUB_ASSETS_URL:-"https://github.githubassets.com"}
  GITHUB_GIST_URL=${GITHUB_GIST_URL:-"https://gist.github.com"}
  GITHUB_AVATAR_URL=${GITHUB_AVATAR_URL:-"https://avatars.githubusercontent.com"}
  GITHUB_MEDIA_URL=${GITHUB_MEDIA_URL:-"https://media.githubusercontent.com"}
  GITHUB_OBJECTS_URL=${GITHUB_OBJECTS_URL:-"https://objects.githubusercontent.com"}
  GITHUB_CODELOAD_URL=${GITHUB_CODELOAD_URL:-"https://codeload.github.com"}

  if ! check_network >/dev/null 2>&1; then
    GITHUB_URL="https://hub.llll.host"
    GITHUB_RAW_URL="https://raw.llll.host"
    GITHUB_ASSETS_URL="https://assets.llll.host"
    GITHUB_GIST_URL="https://gist.llll.host"
    GITHUB_AVATAR_URL="https://avatars.llll.host"
    GITHUB_MEDIA_URL="https://media.llll.host"
    GITHUB_OBJECTS_URL="https://object.llll.host"
    GITHUB_CODELOAD_URL="https://download.llll.host"
  fi
}

is_wsl() {
  case "$(uname -r)" in
  *microsoft*) true ;; # WSL 2
  *Microsoft*) true ;; # WSL 1
  *) false ;;
  esac
}

is_darwin() {
  case "$(uname -s)" in
  *darwin*) true ;;
  *Darwin*) true ;;
  *) false ;;
  esac
}

set_var() {
  user="$(id -un 2>/dev/null || true)"
  sh_c="sh -c"
  if [ "$user" != "root" ]; then
    if command_exists sudo; then
      sh_c="sudo -E sh -c"
    elif command_exists su; then
      sh_c="su -c"
    else
      printf >&2 "Error: this installer needs the ability to run commands as root.\n"
      printf >&2 "We are unable to find either \"sudo\" or \"su\" available to make this happen.\n"
      exit 1
    fi
  fi

  lsb_dist=$(get_distribution)
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
}

set_var


BASE_URL="https://raw.githubusercontent.com/aliuq/run/refs/heads/master"

# 更新软件包
update_packages() {
  log "更新软件包"
  if $force || read_confirm "是否更新软件包? (y/n): "; then
    log "正在更新软件包..."
    case $lsb_dist in
    ubuntu) run "apt update -y && apt upgrade -y" ;;
    *) log "$(red "[$lsb_dist] 暂不支持")" ;;
    esac

    log "$(green "软件包更新成功")"
  fi
}

# 修改主机名
change_hostname() {
  log "修改主机名称"

  if $force || read_confirm "是否修改主机名? (y/n): "; then
    local new_hostname=$(read_input "请输入新的主机名: ")
    [ -z "$new_hostname" ] && log "$(yellow '主机名不能为空, Skipping...')" && return

    local old_hostname=$(hostname)
    run "sed -i 's/$old_hostname/$new_hostname/g' /etc/hosts"
    run "hostnamectl set-hostname $new_hostname"
    ! $dry_run && log_success "主机名修改成功, $(cyan "$old_hostname") => $(cyan "$(hostname)")"
  fi
}

# 修改 ssh 端口

change_ssh_port() {
  log "修改 SSH 端口"

  if $force || read_confirm "是否修改 SSH 端口? (y/n): "; then
    local new_port=$(read_input "请输入新的 SSH 端口, 建议使用 2222: ")
    [ -z "$new_port" ] && log "$(yellow '端口不能为空, Skipping...')" && return

    local old_port="22"
    if grep -q "^Port" /etc/ssh/sshd_config; then
      old_port=$(grep -oP "^Port \K.*" /etc/ssh/sshd_config)
      log "原 SSH 端口配置为未注释状态"
    else
      log "原 SSH 端口配置为注释状态"
    fi

    run "sed -i '/^#\?Port /c\Port $new_port' /etc/ssh/sshd_config"

    case $lsb_dist in
    ubuntu) run "systemctl restart ssh" ;;
    centos) run "systemctl restart sshd" ;;
    *) log "$(red "[$lsb_dist] 暂不支持")" ;;
    esac

    ! $dry_run && log_success "SSH 端口已修改，$(cyan "$old_port") => $(cyan "$new_port")"

    echo
    yellow "=> 在云服务器中修改，需要在云服务商的安全组中开放新的 SSH 端口 $(cyan $new_port)"
    yellow "=> 最后不要忘了重启服务器 $(cyan "sudo reboot")"

    read_confirm "是否立即重启服务器？(y/n): " && run "sudo reboot"
  fi
}


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
  if ! command_exists zoxide; then
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


preset=""
show_system=false
while [ $# -gt 0 ]; do
  case "$1" in
  --preset)
    preset="$2"
    shift
    ;;
  --preset=*) preset="${1#*=}" ;;
  --show-system) show_system=true ;;
  --*) echo "Illegal option $1" ;;
  esac
  shift $(($# > 0 ? 1 : 0))
done

if $help; then
  yellow "\n暂未实现 help 功能"
  exit 0
fi

do_prepare() {
  info "准备脚本开发环境"
  command_exists curl || run "apt update -y && apt install -y curl" && info "$(green '✔ curl 安装成功')"
  command_exists jq || run "apt update -y && apt install -y jq" && info "$(green '✔ jq 安装成功')"
  info "脚本开发环境准备完毕"
}

echo_dividerline() {
  echo "-------------------------------------------------------"
}

echo_info() {
  clear
  echo $(cyan "$(bold "RunShell by AliuQ")")
  echo_dividerline
  printf "仓库地址      : $(cyan_bright 'https://github.com/aliuq/run')\n"
  printf "User/Host     : $(cyan_bright "$(whoami)")@$(cyan_bright "$(hostname)")\n"

  if [ -f /etc/os-release ]; then
    . /etc/os-release && THE_OS="$NAME $VERSION"
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release && THE_OS="$DISTRIB_ID $DISTRIB_RELEASE"
  else
    THE_OS="Unknown"
  fi
  echo "系统          : $(cyan_bright "$THE_OS")"
  echo "默认终端      : $(cyan_bright "$SHELL $TERM")"
  echo "系统在线时间  : $(cyan_bright "$(uptime -p | sed 's/up //')")"
  echo "IP 地址       : $(hostname -I) / $(cyan_bright "$(get_ip)")"

  tput sc
  echo "连通性检查    : $(yellow "请稍候……")"
  local conn_github="Github $(cyan_bright "$(check_network github)")"
  local conn_google="Google $(cyan_bright "$(check_network google)")"
  local conn_cf="Cloudflare $(cyan_bright "$(check_network cloudflare)")"
  tput rc && tput ed
  echo "连通性检查    : $conn_github / $conn_google / $conn_cf"

  ip_info=$(curl -sL https://myip.ipip.net/json | jq -r '.data.location | [.[0], .[1], .[2], .[3], .[4]] | @csv' | sed 's/,/ /g' | sed 's/"//g')
  echo "网络          : $(cyan_bright "$ip_info")"

  $show_system && echo_system_info
}

# 显示系统信息
echo_system_info() {
  echo "-------------------------------------------------------"
  # CPU 缓存: L1: 32 KiB / L2: 512 KiB / L3: 32 MiB
  cpu_info=$(lscpu | awk '/L1d cache/ {L1=$3 " " $4} /L2 cache/ {L2=$3 " " $4} /L3 cache/ {L3=$3 " " $4} END {printf "L1: %s / L2: %s / L3: %s", L1, L2, L3}')
  echo "CPU 缓存      : $(cyan_bright "$cpu_info")"

  # 内存: 已用 / 总大小
  mem_info=$(free -h | awk '/Mem/{print $3 " / " $2}')
  echo "内存          : $(cyan_bright "$mem_info")"

  # Swap: 已用 / 总大小
  swap_info=$(free -h | awk '/Swap/{print $3 " / " $2}')
  echo "Swap          : $(cyan_bright "$swap_info")"

  # 负载
  loadavg=$(uptime | awk -F 'load average: ' '{print $2}' | awk '{print $1, $2, $3}')
  echo "负载          : $(cyan_bright "$loadavg")"

  # 硬盘空间: 已用 / 总大小
  disk_info=$(df -h / | awk '/\//{print $3 " / " $2}')
  echo "硬盘空间      : $(cyan_bright "$disk_info")"

  # 启动盘路径: /dev/vda1
  boot_disk=$(df / | awk '/\//{print $1}')
  echo "启动盘路径    : $(cyan_bright "$boot_disk")"

  echo "架构          : $(cyan_bright "$(uname -m)")"
  echo "内核          : $(cyan_bright "$(uname -r)")"
}

echo_commands() {
  echo
  echo
  echo $(magenta "系统")
  echo_dividerline
  echo "$(green "1.") 更新软件包        $(green "2.") 修改主机名        $(green "3.") 修改 ssh 端口        $(green "q.") 退出"
  echo
  echo $(magenta "配置")
  echo_dividerline
  echo "$(green "100.") 安装 zsh            $(green "101.") 安装快捷工具            $(green "102.") 安装 ohmyzsh"
  echo "$(green "103.") 生成 ssh 密钥       $(green "104.") 添加 waketime           $(green "105.") 添加 docker 镜像"
  echo "$(green "106.") 安装基础工具"
  echo
  echo $(magenta "前端")
  echo_dividerline
  echo "$(green "301.") 安装 fnm"
  echo

  if [ -n "$preset" ]; then
    command_index=$preset
    info "==> 选择了预设值: $(cyan $preset)"
    echo
  else
    command_index=$(read_input "$(magenta "=> 请输入要执行的命令编号:") ")
    echo
  fi

  case $command_index in
  1) update_packages ;;
  2) change_hostname ;;
  3) change_ssh_port ;;
  100) install_zsh ;;
  101) install_tools ;;
  102) install_ohmyzsh ;;
  103) generate_ssh_key ;;
  104) add_waketime ;;
  105) add_docker_mirror ;;
  106) install_basic_tools ;;
  301) install_fnm ;;
  [qQ] | [eE][xX][iI][tT] | [qQ][uU][iI][tT])
    info "Exit"
    exit 0
    ;;
  *)
    red "未知命令: $command_index"
    exit 1
    ;;
  esac
}

do_prepare
set_network
REPO_URL="$GITHUB_RAW_URL/aliuq/run/refs/heads/master"
echo_info
echo_commands

