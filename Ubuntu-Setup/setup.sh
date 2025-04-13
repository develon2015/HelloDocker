function main() {
  rust
  echo "OK"
}

main

function rust() {
    snap install rustup --classic
    rustup default stable
}
