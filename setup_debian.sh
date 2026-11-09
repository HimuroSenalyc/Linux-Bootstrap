#!/usr/bin/env bash

echo ">>> 正在更新系统并安装基础工具..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential cmake clangd kitty wl-clipboard

echo ">>> 正在下载并安装最新版 Neovim..."
# 下载最新的 nvim-linux-x86_64.tar.gz
curl -L -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.tar.gz
tar -zxvf /tmp/nvim.tar.gz -C /tmp
mkdir -p ~/.local/bin ~/.local/share ~/.local/lib
cp /tmp/nvim-linux-x86_64/bin/nvim ~/.local/bin/
cp -r /tmp/nvim-linux-x86_64/share/nvim ~/.local/share/
cp -r /tmp/nvim-linux-x86_64/lib/nvim ~/.local/lib/

# 把环境变量加进 bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

echo ">>> 正在部署 Neovim 配置..."
mkdir -p ~/.config/nvim
cp ./configs/init.lua ~/.config/nvim/

echo ">>> 安装完成！请运行 source ~/.bashrc 并重启终端。"
