#!/bin/bash
#
# Usage:
#

BASE_URL=${BASE_URL:-"https://raw.githubusercontent.com/aliuq/run/refs/heads/master"}

if echo "$BASE_URL" | grep -qE '^https?://'; then
  is_remote=true
else
  is_remote=false
fi

if $is_remote; then
  . /dev/stdin <<EOF
$(curl -sSL $BASE_URL/helper.sh)
$(curl -sSL $BASE_URL/mods/system.sh)
$(curl -sSL $BASE_URL/mods/config.sh)
EOF
else
  . $BASE_URL/helper.sh
  . $BASE_URL/mods/system.sh
  . $BASE_URL/mods/config.sh
fi

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

# BASE_URL=/workspaces/run/ sh test/start.sh --preset 101
