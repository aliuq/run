#!/bin/bash
#
# Usage:
#

# . /workspaces/run/helper.sh
source <(curl -sSL https://raw.githubusercontent.com/aliuq/run/refs/heads/master/helper.sh?token=GHSAT0AAAAAACYX6PRB5XSYJ53BDHDDXW5QZZAFBYA)

preset=""
while [ $# -gt 0 ]; do
  case "$1" in
  --preset)
    preset="$2"
    shift
    ;;
  --*)
    echo "Illegal option $1"
    ;;
  esac
  shift $(($# > 0 ? 1 : 0))
done

if $help; then
  yellow "\n暂未实现 help 功能"
  exit 0
fi

verbose=true

echo_info() {
  # 获取完整的系统信息
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION"
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS_NAME="$DISTRIB_ID"
    OS_VERSION="$DISTRIB_RELEASE"
  else
    OS_NAME="Unknown"
    OS_VERSION="Unknown"
  fi

  # CPU 缓存: L1: 32 KiB / L2: 512 KiB / L3: 32 MiB
  cpu_info=$(lscpu | awk '/L1d cache/ {L1=$3 " " $4} /L2 cache/ {L2=$3 " " $4} /L3 cache/ {L3=$3 " " $4} END {printf "L1: %s / L2: %s / L3: %s", L1, L2, L3}')
  # 硬盘空间: 已用 / 总大小
  disk_info=$(df -h / | awk '/\//{print $3 " / " $2}')
  # 启动盘路径: /dev/vda1
  boot_disk=$(df / | awk '/\//{print $1}')
  # 内存: 已用 / 总大小
  mem_info=$(free -h | awk '/Mem/{print $3 " / " $2}')
  # Swap: 已用 / 总大小
  swap_info=$(free -h | awk '/Swap/{print $3 " / " $2}')
  # 系统在线时间: 1 day, 2 hours 3 minutes
  uptime_info=$(uptime -p | sed 's/up //')
  # 负载
  loadavg=$(uptime | awk -F 'load average: ' '{print $2}' | awk '{print $1, $2, $3}')
  # 系统: Debian GNU/Linux 10 (buster) (x86_64)
  # 架构: x86_64
  # 内核: 5.4.0-80-generic
  ip_info=$(curl -sL https://myip.ipip.net/json | jq -r '.data.location | [.[0], .[1], .[2], .[3], .[4]] | @csv' | sed 's/,/ /g' | sed 's/"//g')

  echo
  # clear
  echo $(cyan "$(bold "RunShell by AliuQ")")
  echo "-------------------------------------------------------"
  printf "仓库地址      : %s\n" $(cyan_bright "https://github.com/aliuq/run")
  printf "默认终端      : %s\n" $(cyan_bright "$SHELL")
  printf "User/Host     : %s\n" $(cyan_bright "$(whoami)@$HOSTNAME")
  printf "IP 地址       : $(hostname -I) / $(cyan_bright "$(curl -sL https://ip.llll.host)")\n"
  printf "系统在线时间  : $(cyan_bright "$uptime_info")\n"
  printf "连通性检查    : Github $(cyan_bright "$(check_network github)") / Google $(cyan_bright "$(check_network google)") / Cloudflare $(cyan_bright "$(check_network cloudflare)")\n"
  printf "网络          : $(cyan_bright "$ip_info")\n"

  if $verbose; then
    echo "-------------------------------------------------------"
    printf "CPU 缓存      : $(cyan_bright "$cpu_info")\n" 
    printf "硬盘空间      : $(cyan_bright "$disk_info")\n" 
    printf "启动盘路径    : $(cyan_bright "$boot_disk")\n"
    printf "内存          : $(cyan_bright "$mem_info")\n"
    printf "Swap          : $(cyan_bright "$swap_info")\n"
    printf "负载          : $(cyan_bright "$loadavg")\n"
    printf "系统          : $(cyan_bright "$OS_NAME $OS_VERSION")\n"
    printf "架构          : $(cyan_bright "$(uname -m)")\n"
    printf "内核          : $(cyan_bright "$(uname -r)")\n"
  fi
}

echo_info

