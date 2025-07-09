install_fnm() {
  log "安装 fnm"
  tput bold
  echo
  echo "$(cyan fnm) 是一个使用 rust 构建的 Node.js 版本管理工具, 适用于.node-version和.nvmrc文件"
  echo
  echo "Repository: $(cyan "https://github.com/Schniz/fnm")"
  echo "Source: $(cyan "https://github.com/Schniz/fnm/blob/master/.ci/install.sh")"
  tput sgr0

  if [ "$current_shell" != "bash" ] && [ "$current_shell" != "zsh" ]; then
    red "当前 shell 仅支持 bash 和 zsh"
    exit 1
  fi

  if $force || read_confirm "是否安装 fnm? (y/n): "; then
    command_exists curl || run "apt update -y && apt install -y curl"
    command_exists unzip || run "apt update -y && apt install -y unzip"

    # 安装脚本: https://github.com/Schniz/fnm/blob/master/.ci/install.sh
    # 由于脚本存在中存在固定的 https://github.com，需要通过先下载到本地，进行替换
    local tmpPath="/tmp/fnm-install.sh"

    run "curl -fsSL \"${PROXY_URL}https://fnm.vercel.app/install\" -o $tmpPath"
    # 替换脚本中的 https://github.com 为代理地址 $PROXY_URL
    run "sed -i 's|https://github.com|$GITHUB_URL|g' $tmpPath"
    run "bash $tmpPath --install-dir $HOME/.fnm --skip-shell"
    run "chmod +x $HOME/.fnm/fnm"

    # 判断终端配置文件中是否已经包含 fnm 的配置
    if ! grep -q "# fnm" $current_shell_rc && ! $dry_run; then
      log "Installing for $current_shell. Appending the following to $current_shell_rc:"

      {
        echo ''
        echo '# fnm'
        echo 'FNM_PATH="$HOME/.fnm"'
        echo 'if [ -d "$FNM_PATH" ]; then'
        echo '  export PATH="$FNM_PATH:$PATH"'
        echo '  eval "$(fnm env --use-on-cd --shell '$current_shell')"'
        echo '  eval "$(fnm completions --shell '$current_shell')"'
        echo 'fi'
      } | tee -a "$current_shell_rc"
    fi

    run "rm -f $tmpPath"

    if ! $dry_run; then
      echo ""
      echo $(green "fnm 安装完成")$(gray ", 请重新打开终端或运行")$(cyan " source $current_shell_rc ")$(gray "使配置生效, 如果出现以下错误: ")
      red "\n  error: Can't download the requested binary: Permission denied (os error 13)\n"
      echo $(gray "这是因为还没有安装任何一个版本，请尝试运行")$(cyan " fnm install --lts ")$(gray "进行手动安装")
    fi
  fi
}
