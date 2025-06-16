# 安装
https://docs.docker.com/engine/install/


# Linux 版 Docker 引擎
Github: https://github.com/docker/for-linux

获取适用于 Linux 的 Docker 引擎
Docker Engine for Linux 是常见 Linux 发行版的专用软件包，可以免费下载: https://download.docker.com/linux/static/stable/
```
Index of linux/static/stable/
../
aarch64/
armel/
armhf/
ppc64le/
s390x/
x86_64/
```


# 从二进制文件安装 Docker Engine
https://docs.docker.com/engine/install/binaries/

```
wget https://download.docker.com/linux/static/stable/x86_64/docker-17.03.0-ce.tgz
tar xzvf docker-17.03.0-ce.tgz

# 添加PATH
vi ~/.bashrc
PATH="/root/docker/bin:$PATH"

# 推荐移动到系统目录下
mv * /usr/bin
```


# 启动
先启动守护进程docker：
```
# dockerd
INFO[0000] libcontainerd: new containerd process, pid: 10699
INFO[0001] Graph migration to content-addressability took 0.00 seconds
INFO[0001] Loading containers: start.
INFO[0001] Firewalld running: false
INFO[0001] Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address
INFO[0001] Loading containers: done.
INFO[0001] Daemon has completed initialization
INFO[0001] Docker daemon                                 commit=3a232c8 graphdriver=overlay version=17.03.0-ce
INFO[0001] API listen on /var/run/docker.sock
```
docker命令可用，但是运行容器报错：
```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

# docker run hello-world
docker: Error response from daemon: missing signature key.
See 'docker run --help'.
```
自从注册表开始使用 v2 模式后，你就不能使用版本早于 18.06 的 docker 拉取镜像了。
因此需要安装 `18.06` 及以上版本的docker。


# 守护进程代理配置
https://docs.docker.com/engine/daemon/proxy/

一些公共镜像可以通过阿里云拉取：
```
docker pull registry.cn-beijing.aliyuncs.com/supermap/yukon:2.0-opengauss5.0.0-amd64
```

## 修改配置文件: /etc/docker/daemon.json
```
{
  "proxies": {
    "http-proxy": "http://proxy.example.com:3128",
    "https-proxy": "https://proxy.example.com:3129",
    "no-proxy": "*.test.example.com,.example.org,127.0.0.0/8"
  }
}
```
比如：
```
{
  "proxies": {
    "http-proxy": "http://192.168.0.140:25378",
    "https-proxy": "http://192.168.0.140:25378",
    "no-proxy": "192.168.0.1/32,127.0.0.0/8"
  }
}
```
然后重启docker：
```
sudo systemctl restart docker
```

## 修改守护进程的环境变量
参考：https://www.cnblogs.com/develon/p/18707416
```
PROXY=http://8.210.99.219:45378
PROXY=socks5h://8.210.99.219:48082  # dockerd不支持socks5h协议
PROXY=socks5://8.210.99.219:48082  # 修改 /etc//etc/resolv.conf 设置 nameserver 114.114.114.114

http_proxy=$PROXY https_proxy=$PROXY curl -v https://registry-1.docker.io/v2/

sudo systemctl stop docker
sudo http_proxy=$PROXY https_proxy=$PROXY /usr/sbin/dockerd
```


# 拉取指定平台镜像
首先可能需要在 Docker daemon 配置文件中配置 `"experimental": true` 开启实验性功能，然后重启dockerd：
```
$ vi /etc/docker/daemon.json
{
  "experimental": true
}

sudo systemctl stop docker
sudo http_proxy=$PROXY https_proxy=$PROXY /usr/sbin/dockerd
```
然后就可以拉取指定平台镜像了：
```
sudo docker pull --platform linux/amd64 imgxx/remote-bind

sudo docker pull --platform linux/aarch64 imgxx/remote-bind
sudo docker pull --platform linux/arm64 imgxx/remote-bind
```


# 注册为服务
https://github.com/moby/moby/tree/master/contrib/init/systemd

注意，首先创建 docker 用户组！并禁用 containerd ！
```
groupadd docker

cd /etc/systemd/system
vi docker.service
vi docker.socket
```

## docker.service
```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target nss-lookup.target docker.socket firewalld.service containerd.service time-set.target
# 注释下面这行
# Wants=network-online.target containerd.service
Requires=docker.socket
StartLimitBurst=3
StartLimitIntervalSec=60

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
# 修改下面这行，不要使用 containerd
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

## docker.socket
```
[Unit]
Description=Docker Socket for the API

[Socket]
# If /var/run is not implemented as a symlink to /run, you may need to
# specify ListenStream=/var/run/docker.sock instead.
ListenStream=/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
```

## containerd
据悉是一个开放可靠的容器运行时，不知道为什么需要这个东西，禁止似乎也没影响
```
# /usr/bin/containerd -v
containerd github.com/containerd/containerd 1.7.24
```

查看 Ubuntu22.04 上的 `/usr/lib/systemd/system/containerd.service` 文件：
```
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target dbus.service

[Service]
#uncomment to enable the experimental sbservice (sandboxed) version of containerd/cri integration
#Environment="ENABLE_CRI_SANDBOXES=sandboxed"
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

## 启用服务
```
# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /etc/systemd/system/docker.service.
```

#
