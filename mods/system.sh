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
