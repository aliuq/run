#!/bin/bash
#
# Usage:
#

. /workspaces/run/helper.sh

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
  OS=$(uname -s)
  KERNEL_VERSION=$(uname -r)
  USERNAME=$(whoami)

  # 检查是否在 WSL 环境中
  if grep -qi microsoft /proc/version; then
    IS_WSL="Yes"
  else
    IS_WSL="No"
  fi

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

  UPTIME_RAW=$(uptime -p)
  UPTIME_CN=$(echo "$UPTIME_RAW" | sed \
    -e 's/up //g' \
    -e 's/ week/周/g' \
    -e 's/ days/天/g' \
    -e 's/ day/天/g' \
    -e 's/ hours/小时/g' \
    -e 's/ hour/小时/g' \
    -e 's/ minutes/分钟/g' \
    -e 's/ minute/分钟/g' \
    -e 's/,//g' \
    -e 's/ and / /g')

  echo
  clear
  printf "脚本名称    : $(white "个人开发环境管理脚本")\n"
  printf "脚本地址    : https://github.com/aliuq/config/blob/master/run.sh\n"
  printf "描述        : 记录一些本人经常使用的脚本操作\n"
  printf "Shell       : %s\n" "$SHELL"
  printf "Hostname    : %s\n" "$(hostname)"
  printf "Username    : %s\n" "$USERNAME"
  printf "IP          : %s\n" "$(hostname -I)"
  printf "公网 IP     : %s\n" "$(green "$(curl -sL https://ip.llll.host)")"
  printf "系统运行时间: %s\n" "$UPTIME_CN"

  if $verbose; then
    echo "_________________________________________\n"
    printf "系统        : %s %s\n" "$OS_NAME" "$OS_VERSION"
    printf "内核        : %s\n" "$KERNEL_VERSION"
    printf "是否是 WSL  : %s\n" "$IS_WSL"
    printf "系统架构    : %s\n" "$(uname -m)"
    printf "Home        : %s\n" "$HOME"
    printf "当前目录    : %s\n" "$(pwd)"
    echo
  fi
}

echo_info
