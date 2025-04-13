apt update

apt install tmux wget curl -y

tmux new -s setup 'bash -c "wget https://github.com/develon2015/HelloDocker/raw/refs/heads/main/Ubuntu-Setup/setup.sh && bash setup.sh; bash"'
