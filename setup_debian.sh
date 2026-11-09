#!/usr/bin/env bash

echo ">>> 正在更新系统并安装基础工具..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential cmake clangd kitty wl-clipboard pipx

echo ">>> 正在下载并安装最新版 Neovim..."
curl -L -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.tar.gz
tar -zxvf /tmp/nvim.tar.gz -C /tmp
mkdir -p ~/.local/bin ~/.local/share ~/.local/lib
cp /tmp/nvim-linux-x86_64/bin/nvim ~/.local/bin/
cp -r /tmp/nvim-linux-x86_64/share/nvim ~/.local/share/
cp -r /tmp/nvim-linux-x86_64/lib/nvim ~/.local/lib/

# 把环境变量加进 bashrc (防呆：如果没加过才加)
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo ">>> 正在配置 CMake LSP (pipx 隔离安装)..."
# 防呆：检查是否安装，防止重复运行报错
if ! command -v cmake-language-server &> /dev/null; then
    pipx install cmake-language-server
fi

echo ">>> 正在下载 Neovide (AppImage)..."
if [ ! -f ~/.local/bin/neovide.AppImage ]; then
    # 这里用了 ghproxy 镜像，防止部分网络环境拉不下来
    wget https://ghproxy.net/https://github.com/neovide/neovide/releases/latest/download/neovide.AppImage -O ~/.local/bin/neovide.AppImage
    chmod +x ~/.local/bin/neovide.AppImage
    ln -sf ~/.local/bin/neovide.AppImage ~/.local/bin/neovide
fi

echo ">>> 正在部署 Neovim 配置..."
mkdir -p ~/.config/nvim
cp ./configs/init.lua ~/.config/nvim/

echo ">>> 安装完成！请运行 source ~/.bashrc 并重启终端，或者直接输入 neovide 起飞。"
