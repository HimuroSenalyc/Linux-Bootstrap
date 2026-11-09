#!/usr/bin/env bash

# 判断是否为 root 用户执行
if [ "$EUID" -eq 0 ]; then
  echo "请勿使用 sudo 运行此脚本，它会自动申请权限。"
  exit 1
fi

if [ -f /etc/debian_version ]; then
    echo "检测到 Debian 系，准备执行 Debian 配置脚本..."
    bash setup_debian.sh
elif [ -f /etc/arch-release ]; then
    echo "检测到 Arch 系，准备执行 Arch 配置脚本..."
    bash setup_arch.sh
else
    echo "不支持的系统。此脚本仅限 Debian 和 Arch 系。"
    exit 1
fi
