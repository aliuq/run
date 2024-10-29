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

# 更新软件包
update_packages() {
  log "更新软件包"
  if $force || read_confirm "是否更新软件包? (y/n): "; then
    case $lsb_dist in
      ubuntu) run "apt update -y && apt upgrade -y" ;;
      *) red "==> 暂不支持该系统" ;;
    esac
  fi
}

# 修改主机名
change_hostname() {
  log "修改主机名"
  if $force || read_confirm "是否修改主机名? (y/n): "; then
    new_hostname=$(read_input "请输入新的主机名: ")
    [ -z "$new_hostname" ] && info "==> 主机名不能为空, Skipping..." && return

    HOSTNAME=$(hostname)
    info "==> 当前主机名: $HOSTNAME"
    info "==> 新的主机名: $new_hostname"
    run "sed -i 's/$HOSTNAME/$new_hostname/g' /etc/hosts"
    run "hostnamectl set-hostname $new_hostname"
    green "==> 主机名修改成功, 请重新打开终端"
  fi
}
