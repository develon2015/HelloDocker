# https://github.com/nvm-sh/nvm
# Node 版本管理器 - 符合 POSIX 标准的 bash 脚本，用于管理多个活动的 node.js 版本
function nvm_install() {
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
}

# https://github.com/Schniz/fnm
# 快速、简单的 Node.js 版本管理器，采用 Rust 构建
function fvm_install() {
    curl -fsSL https://fnm.vercel.app/install | bash
}

# https://github.com/pkgxdev/pkgx
# 强大的 pkgx 和 pkgm 命令，支持多种软件包命令，支持的软件包列表：https://pkgx.dev/pkgs/
function pkgx_install() {
    curl https://pkgx.sh | sh
}

# 安装 Node.js
function nodejs_install() {
    apt install nodejs npm -y
}

# 安装 Rust
function rust_install() {
    snap install rustup --classic
    rustup default stable
}

function main() {
  rust
  echo "OK"
}

main
