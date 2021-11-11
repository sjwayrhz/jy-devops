#!/bin/bash

echo -e "\033[32m  配置/etc/sysctl.d/k8s.conf文件 \033[0m"

sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.d/k8s.conf


echo -e "\033[32m  安装必要的一些系统工具 \033[0m"
sudo yum install yum-utils device-mapper-persistent-data lvm2 -y

echo -e "\033[32m  添加软件源信息 \033[0m"
sudo wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

echo -e "\033[32m  更新yum源并安装containerd \033[0m"
sudo yum install containerd.io -y

echo -e "\033[32m  修改/etc/containerd/config.toml配置 \033[0m"
sudo containerd config default > /etc/containerd/config.toml

sed -i "s#k8s.gcr.io#registry.cn-hangzhou.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
sed -i "s#https://registry-1.docker.io#https://registry.cn-hangzhou.aliyuncs.com#g"  /etc/containerd/config.toml
sed -i '/containerd.runtimes.runc.options/a\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml

echo -e "\033[32m  启动containerd服务 \033[0m"
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo -e "\033[32m  安装kubeadm、kubelet、kubectl \033[0m"

sudo tee /etc/yum.repos.d/kubernetes.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
 http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
EOF

sudo yum install -y kubelet-$1 kubeadm-$1 kubectl-$1

echo -e "\033[32m  设置containerd作为k8s默认的容器运行时 \033[0m"
sudo crictl config runtime-endpoint /run/containerd/containerd.sock

echo -e "\033[32m  将 kubelet 设置成开机启动 \033[0m"
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet

