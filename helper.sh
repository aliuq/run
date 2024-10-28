#!/bin/bash

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
#
# Another short link:
#
# + https://s.xod.cc/shell-helper
# + https://bit.ly/shell-helper
#
# Another short mirror link:
#
# + https://s.xod.cc/shell-helper-mirror
# + https://bit.ly/shell-helper-mirror

# Colors
# bold="\033[1m"
# red="\033[0;31m"
# green="\033[0;32m"
# yellow="\033[0;33m"
# cyan="\033[0;36m"
# plain="\033[0m"
# dim="\033[2m"

verbose=false
force=false
help=false
dry_run=false

remaining_args=""

for arg in "$@"; do
  case "$arg" in
  --verbose | -v)
    verbose=true
    ;;
  --force | -[yY])
    force=true
    ;;
  --dry-run)
    dry_run=true
    ;;
  --help | -[hH])
    help=true
    ;;
  *)
    remaining_args="$remaining_args $arg"
    ;;
  esac
done

remaining_args=$(echo "$remaining_args" | sed 's/^ *//')
set -- $remaining_args

print_arg_warn() {
  if $verbose; then
    info "Param $(yellow --verbose/-v/--force/-y/--dry-run/--help) will be ignored"
  fi
}

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
  t=$(date "+%Y-%m-%d %H:%M:%S")
  ft=$(cyan "[INFO] $t")
  printf "$ft $(white "$1")\n"
}
info() {
  printf "$1\n"
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

command_valid() {
  if ! command_exists "$1"; then
    if [ -z "$2" ]; then
      red "Error: $1 is not installed or not in PATH"
    else
      red "$2"
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
  fi
  $sh_c "$1"
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
}

# 发送 Webhook 消息
send_webhook() {
  # 如果不存在 MY_WEBHOOK_URL 环境变量，则不发送消息
  if [ -z "$MY_WEBHOOK_URL" ]; then
    yellow "MY_WEBHOOK_URL 环境变量不存在"
    return
  fi

  # 如果不存在消息内容，则不发送消息
  if [ -z "$1" ]; then
    return
  fi

  local content="$1"
  body="{\"content\":\"$content\"}"
  run "curl -X POST -H 'Content-Type: application/json' -d '$body' \"$MY_WEBHOOK_URL\""
}

read_confirm() {
  echo
  read -p "$(green "$1")" confrim
  # 如果 $2 为 true，则取消 echo，否则打印
  [ "$2" = false ] || echo

  case $confrim in
  [yY] | [yY][eE][sS])
    return 0
    ;;
  [nN] | [nN][oO])
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

read_input() {
  read -p "$(green "$1")" input
  case $input in
  "")
    input="$2"
    ;;
  esac
  echo $input
}

read_confirm_and_input() {
  read -p "$(green "$1")" confrim
  case $confrim in
  "" | [yY] | [yY][eE][sS])
    confrim="$2"
    ;;
  [nN] | [nN][oO])
    confrim=""
    ;;
  esac
  echo $confrim
}

# $1: 选项列表
read_from_options_show() {
  if [ -n "$1" ]; then
    echo
    IFS="|"
    index=1
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
  option=$(read_input "$1(默认 $2): " "$2")

  IFS="|"
  index=1
  for item in $3; do
    if [ "$option" = "$index" ]; then
      IFS=":"
      val=$(echo "$item" | cut -d':' -f1)
      echo "$val"
      break
    fi
    index=$(($index + 1))
  done
  unset IFS
}

is_ubuntu() {
  [ -f /etc/lsb-release ] && grep -q "DISTRIB_ID=Ubuntu" /etc/lsb-release
}
is_centos() {
  [ -f /etc/redhat-release ] && grep -q "CentOS" /etc/redhat-release
}
is_debian() {
  [ -f /etc/os-release ] && grep -q "ID=debian" /etc/os-release
}

print_arg_warn
set_var
