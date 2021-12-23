# 指定创建的基础镜像
FROM alpine:3.14.3

# 作者描述信息
MAINTAINER alpine_sshd (i@sjhz.cf)

# 替换阿里云的源
RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories
RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories

# 同步时间

# 更新源、安装openssh 并修改配置文件和生成key 并且同步时间
RUN apk update && \
    apk add --no-cache openssh-server tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key && \
    echo "root:root" | chpasswd

# 开放22端口
EXPOSE 22

# 执行ssh启动命令
CMD ["/usr/sbin/sshd", "-D"]


# docker build -t alpine:sshd .
# docker run -itd -p 10022:22 --name alpine_ssh_v1 alpine:sshd
# ssh root@127.0.0.1 -p10022