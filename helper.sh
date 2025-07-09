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
use_proxy=false

remaining_args=""

for arg in "$@"; do
  case "$arg" in
  --verbose | -v) verbose=true ;;
  --verbose=*) verbose="${arg#*=}" ;;
  --force | -[yY]) force=true ;;
  --force=*) force="${arg#*=}" ;;
  --dry-run) dry_run=true ;;
  --dry-run=*) dry_run="${arg#*=}" ;;
  --use-proxy) use_proxy=true ;;
  --use-proxy=*) use_proxy="${arg#*=}" ;;
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
  [gG]ithub) url="https://raw.githubusercontent.com/aliuq/run/refs/heads/master/start.sh?_=$timestamp" ;;
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

# 设置常见的网络地址
# 国内服务器通常无法正常访问 Github，这里自动设置为国内镜像地址
set_network() {
  if ! check_network github >/dev/null 2>&1 || $use_proxy; then
    GITHUB_URL=${GITHUB_URL:-"https://hub.llll.host"}
    GITHUB_RAW_URL=${GITHUB_RAW_URL:-"https://raw.llll.host"}
    GITHUB_ASSETS_URL=${GITHUB_ASSETS_URL:-"https://assets.llll.host"}
    GITHUB_GIST_URL=${GITHUB_GIST_URL:-"https://gist.llll.host"}
    GITHUB_AVATAR_URL=${GITHUB_AVATAR_URL:-"https://avatars.llll.host"}
    GITHUB_MEDIA_URL=${GITHUB_MEDIA_URL:-"https://media.llll.host"}
    GITHUB_OBJECTS_URL=${GITHUB_OBJECTS_URL:-"https://objects.llll.host"}
    GITHUB_CODELOAD_URL=${GITHUB_CODELOAD_URL:-"https://download.github.com"}
  else
    GITHUB_URL=${GITHUB_URL:-"https://github.com"}
    GITHUB_RAW_URL=${GITHUB_RAW_URL:-"https://raw.githubusercontent.com"}
    GITHUB_ASSETS_URL=${GITHUB_ASSETS_URL:-"https://github.githubassets.com"}
    GITHUB_GIST_URL=${GITHUB_GIST_URL:-"https://gist.github.com"}
    GITHUB_AVATAR_URL=${GITHUB_AVATAR_URL:-"https://avatars.githubusercontent.com"}
    GITHUB_MEDIA_URL=${GITHUB_MEDIA_URL:-"https://media.githubusercontent.com"}
    GITHUB_OBJECTS_URL=${GITHUB_OBJECTS_URL:-"https://objects.githubusercontent.com"}
    GITHUB_CODELOAD_URL=${GITHUB_CODELOAD_URL:-"https://codeload.github.com"}
  fi

  if ! check_network google >/dev/null 2>&1; then
    PROXY_URL=${PROXY_URL:-"https://dl.llll.host/"}
  else
    PROXY_URL=${PROXY_URL:-""}
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
  current_shell=$(basename "$SHELL")

  current_shell_rc=""
  if [ "$current_shell" = "bash" ]; then
    current_shell_rc="$HOME/.bashrc"
  elif [ "$current_shell" = "zsh" ]; then
    current_shell_rc="$HOME/.zshrc"
  fi
}

set_var
