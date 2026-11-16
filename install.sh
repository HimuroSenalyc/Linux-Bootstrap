#!/usr/bin/env bash
set -euo pipefail

# 1. 禁止 root 直接运行（脚本内部会自己申请 sudo）
if [ "$EUID" -eq 0 ]; then
  echo "请勿使用 sudo 运行此脚本，它会自动申请权限。" >&2
  exit 1
fi

# 2. LiveCD / 临时环境检查
if [ -d /run/live ] || findmnt -n -o FSTYPE / 2>/dev/null | grep -qE '^(tmpfs|overlay)$'; then
  echo "[Linux-Bootstrap] 检测到 LiveCD/临时环境，拒绝执行。" >&2
  echo "本脚本仅用于已安装的 Debian 13 / Arch 系统。" >&2
  echo "环境信息：host=$(hostname) user=$(whoami) root=$(findmnt -n -o SOURCE / 2>/dev/null || echo unknown)" >&2
  exit 1
fi

# 3. 读取发行版信息
if [ ! -f /etc/os-release ]; then
  echo "[Linux-Bootstrap] 无法识别系统（缺少 /etc/os-release），退出。" >&2
  exit 1
fi
. /etc/os-release

# 4. 严格匹配 Debian 13 / Arch
case "$ID" in
  debian)
    if [ "${VERSION_ID:-}" != "13" ]; then
      echo "[Linux-Bootstrap] 仅支持 Debian 13，当前为 ${PRETTY_NAME:-Debian $VERSION_ID}，退出。" >&2
      exit 1
    fi
    echo "检测到 Debian 13，准备执行 Debian 配置脚本..."
    exec bash setup_debian.sh
    ;;
  arch)
    # Arch 滚动更新，无 VERSION_ID，认 ID 即可
    echo "检测到 Arch Linux，准备执行 Arch 配置脚本..."
    exec bash setup_arch.sh
    ;;
  *)
    echo "[Linux-Bootstrap] 仅支持 Debian 13 / Arch，当前为 ${PRETTY_NAME:-未知系统}，退出。" >&2
    exit 1
    ;;
esac
