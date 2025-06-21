# lsky-pro

[![PFM-Upstream-Sync](https://github.com/PFM-PowerForMe/lsky-pro/actions/workflows/fork-sync.yml/badge.svg)](https://github.com/PFM-PowerForMe/lsky-pro/actions/workflows/fork-sync.yml)

## 简介
☁️兰空图床(Lsky Pro) - Your photo album on the cloud.

## 如何部署?
1. 前置条件:
```shell
mkdir -p /etc/containers/systemd
podman network create deploy
```

2. 部署 lsky-pro


支持的环境变量(将在安装后重启生效)
```
# REDIS_ENABLE不为空即可,不设置将不生效
REDIS_ENABLE=1

REDIS_HOST
REDIS_PASSWORD
REDIS_PORT

APP_URL

```

```
nvim /etc/containers/systemd/lsky-pro.container
```
```
# /etc/containers/systemd/lsky-pro.container

[Unit]
Description=The lsky-pro container
Wants=network-online.target
After=network-online.target

[Container]
AutoUpdate=registry
ContainerName=lsky-pro
Timezone=local
Network=deploy
LogDriver=journald
Tmpfs=/tmp
Volume=lsky_pro_data:/var/www/html
PublishPort=127.0.0.1:6001:80
Image=ghcr.io/pfm-powerforme/lsky-pro:latest

[Service]
Restart=on-failure
RestartSec=30s
StartLimitInterval=30
TimeoutStartSec=900
TimeoutStopSec=70

[Install]
WantedBy=multi-user.target default.target
```