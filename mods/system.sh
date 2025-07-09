# 更新软件包
#
update_packages() {
  log "更新软件包"
  if $force || read_confirm "是否更新软件包? (y/n): "; then
    log "正在更新软件包..."
    case $lsb_dist in
    ubuntu | debian) run "apt update -y && apt upgrade -y" ;;
    *)
      log "$(red "[$lsb_dist] 暂不支持")"
      exit 1
      ;;
    esac

    log "$(green "软件包更新成功")"
  fi
}

# 修改主机名
#
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
#
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
    ubuntu | debian) run "systemctl restart ssh" ;;
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
