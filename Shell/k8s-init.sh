#!/bin/bash

echo -e "\033[32m  关闭 firewalld 和 selinux  \033[0m"
sudo systemctl disable --now firewalld
sudo sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config

echo -e "\033[32m  创建/etc/sysctl.d/k8s.conf文件  \033[0m"
sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF

sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.d/k8s.conf

echo -e "\033[32m  安装 ipvs  \033[0m"
sudo tee /etc/sysconfig/modules/ipvs.modules <<-'EOF'
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

sudo chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

echo -e "\033[32m  安装了 chrony , ipset 软件包 和 ipvsadm 管理工具   \033[0m"
sudo yum install ipset ipvsadm chronyd -y
sudo systemctl enable --now chronyd

echo -e "\033[32m  关闭 swap 分区   \033[0m"
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab 

