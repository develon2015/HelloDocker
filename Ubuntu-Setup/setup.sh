function rust() {
    snap install rustup --classic
    rustup default stable
}

function main() {
  rust
  echo "OK"
}

main
