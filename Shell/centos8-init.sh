#!/usr/bin/env bash
# Author: i@sjhz.cf
# curl -fsSL https://gitee.com/sjwayrhz/devops/raw/develop/Shell/centos8-init.sh | bash -s -- \
#    --fqdn=blog.sjhz.tk \
#    --user=sjhz \
#    --port=22 \
#    --repo=ali \
#    --tz=Asia/Shanghai
set -e
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPTNAME="${0##*/}"
ARGS="$*"


usage(){
    echo "Usage: /PATH/SCRIPTNAME [[--]fqdn=FQDN] [[--]port=PORT] [ [--]user=USERNAME [[--]passwd=PASSWORD] [[--]keyPasswd=PASSWORD] ] [[--]repo={ali|ALI}] [[--]tz={Asia/Shanghai|...}] [[--]help]"
}

setALI(){
    centos_repo=http://mirrors.aliyun.com/repo/Centos-8.repo
}

getArguments(){
for i in $ARGS; do
    case $i in
        --fqdn=?*|fqdn=?*)
            eval ${i#--}
            ;;
        --port=?*|port=?*)
            eval ${i#--}
            ;;
        --user=?*|user=?*)
            eval ${i#--}
            ;;
        --passwd=?*|passwd=?*)
            eval ${i#--}
            ;;
        --keyPasswd=?*|keyPasswd=?*)
            eval ${i#--}
            ;;
        --repo=?*|repo=?*)
            eval ${i#--}
            [[ $repo = ali || $repo = ALI ]] && setALI;
            ;;
        --tz=?*|tz=?*)
            eval ${i#--}
            ;;
        --help|help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 3
            ;;
    esac
done

if [[ -z $user ]] && ( [[ -z $passwd ]] && [[ -z $keyPasswd ]] ); then  # 不传入用户名参数，不创建用户
    createuser=false
elif [[ -z $user ]] && ( [[ -n $passwd ]] || [[ -n $keyPasswd ]] ); then  # 只传入密码参数无用户名参数，返回脚本用法并退出
    usage; exit 4
fi
}

setDefaultVariables(){
    full_domain="${fqdn}"
    my_hostname=${full_domain%%.*}
    my_ip=`hostname -I | awk '{print $1}'`
    checkPort=`awk '/^Port/{print $2}' /etc/ssh/sshd_config`
    current_port="${checkPort:-22}"
    ssh_port="${port}"
    new_user="${user}"
    password16="${passwd:-`tr -dc '[:alnum:]' < /dev/urandom | head -c 16`}"
    password8="${keyPasswd:-`tr -dc '[:digit:][:lower:]' < /dev/urandom | head -c 8`}"
    repo="${centos_repo}"
    time_zone="${tz}"
}

setGlobalVariables(){
    _fqdn="${full_domain}"
    _hostname=${my_hostname}
    _ip=${my_ip}
    _currentport="${current_port}"
    _sshport="${ssh_port}"
    _user="${new_user}"
    _password="${password16}"
    _passwd_key="${password8}"
    _repo="${repo}"
    _tz="${time_zone}"
}

updateOS(){
  if [[ -n $_repo ]]; then
      if [[ ! -f /etc/yum.repos.d/CentOS-Linux-BaseOS.repo.origin ]]; then cp /etc/yum.repos.d/CentOS-Linux-BaseOS.repo{,.origin}; fi
      curl -o /etc/yum.repos.d/CentOS-Linux-BaseOS.repo $_repo || wget -O /etc/yum.repos.d/CentOS-Linux-BaseOS.repo $_repo
      sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/CentOS-Linux-AppStream.repo
      sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/CentOS-Linux-Extras.repo
  fi

    setenforce 0 || true
    sed -i 's/SELINUX=enforcing\|SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config  # 无判断，直接替换

    #yum clean all
    #yum -y update  # 手动执行吧！
    yum -y upgrade
    yum -y install epel-release vim net-tools
}

setHostname(){
  if [[ -n $_hostname ]]; then
    hostname $_hostname
    echo $_hostname > /etc/hostname
    if ! grep -q "$_ip $_fqdn $_hostname" /etc/hosts; then
        echo "$_ip $_fqdn $_hostname" >> /etc/hosts
    fi
  fi
}

setProfile(){
if [[ ! -f /etc/profile.d/myProfile.sh ]]; then

    tee /etc/profile.d/myProfile.sh <<- EOF
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL="ignoreboth" 
alias lt='ls -alt --color=auto'
umask 022
export TMOUT=3600
EOF

fi
}

setTimezone(){
  if [[ -n $_tz ]]; then
    timedatectl set-timezone $_tz
  fi

    systemctl restart chronyd
    systemctl enable chronyd
    chronyc -a makestep
}
createUser(){
  if [[ ! $createuser = false ]]; then
    if ! id -u $_user &> /dev/null; then
        iscreate=true
        useradd -m $_user -s /bin/bash
        eval chpasswd <<< "$_user:$_password"

        if [[ ! -f /etc/sudoers.d/${_user}.nopasswd ]]; then
            echo -e "${_user}\tALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${_user}.nopasswd
        fi

        mkdir /home/$_user/.ssh
        chown $_user:$_user /home/$_user/.ssh
        chmod 700 /home/$_user/.ssh
        sudo -u $_user ssh-keygen -qf /home/$_user/.ssh/id_rsa.$_user -t rsa -N $_passwd_key
        cat /home/$_user/.ssh/id_rsa.$_user.pub > /home/$_user/.ssh/authorized_keys
        chown $_user:$_user /home/$_user/.ssh/authorized_keys
        chmod 600 /home/$_user/.ssh/authorized_keys
    else
        iscreate=false
        echo -en "\033[33m[Warning] \033[0m"
        echo "User: $_user exist!"
    fi
  else
    iscreate=false
  fi
}

setSSHD(){
    if [[ ! -f /etc/ssh/sshd_config.origin ]]; then cp /etc/ssh/sshd_config{,.origin}; fi

    if $iscreate; then  # 如果成功创建用户
        if grep -Eq '^PermitRootLogin (yes|no)$' /etc/ssh/sshd_config; then
            sed -ri -e 's/^(PermitRootLogin )yes$/\1no/' /etc/ssh/sshd_config
        else
            echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
        fi
    
        if grep -Eq '^PasswordAuthentication (yes|no)$' /etc/ssh/sshd_config; then
            sed -ri -e 's/^(PasswordAuthentication )yes$/\1no/' /etc/ssh/sshd_config
        else
            echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
        fi
    fi

    if [[ -n $_sshport ]]; then  # 如果指定ssh端口
        if [[ ! $_sshport = $_currentport ]]; then  # 如果端口不一致
            if grep -q '^Port [0-9]\+' /etc/ssh/sshd_config; then  # 如果配置文件有指定Port
                sed -ri 's/^Port [0-9]+/Port '"$_sshport"'/' /etc/ssh/sshd_config
            else  # 如果配置文件没有指定Port，比如默认22端口的情况
                echo "Port $_sshport" >> /etc/ssh/sshd_config
            fi
        fi
    fi

    systemctl reload sshd
}

setFirewall(){
#if firewall-cmd --state &> /dev/null; then
if systemctl is-active firewalld; then  # 如果firewalld服务开启才执行以下动作
    if [[ -n $_sshport ]]; then  # 如果指定ssh端口
        if [[ ! $_sshport = $_currentport ]]; then  # 如果端口不一致，删除当前规则，添加新规则
          firewall-cmd --zone=public --remove-port=${_currentport}/tcp --permanent &> /dev/null
          firewall-cmd --zone=public --add-port=${_sshport}/tcp --permanent &> /dev/null
        else  # 如果端口一致，检测是否有防火墙规则，无则添加
          firewall-cmd --zone=public --add-port=${_sshport}/tcp --permanent &> /dev/null
        fi
    else  # 如果不指定ssh端口，检测是否有防火墙规则，无则添加
        firewall-cmd --zone=public --add-port=${_currentport}/tcp --permanent &> /dev/null
    fi

    firewall-cmd --zone=public --add-service=http --add-service=https --permanent &> /dev/null
    firewall-cmd --reload
fi
}

printInfo(){
    runScriptDate=`date`
    echo '**************************************** End ****************************************'
    echo "Output -> /root/$SCRIPTNAME.log"

    if $iscreate; then
        cat >> /root/$SCRIPTNAME.log <<- EOF
$runScriptDate
Arguments: $ARGS
------------------------------------------------------------------------------------------
User Name: $_user
User Password: $_password
SSH Port: $_sshport
Private Key(id_rsa.$_user):
$(cat /home/$_user/.ssh/id_rsa.$_user)
Password(id_rsa.$_user): $_passwd_key
FQDN: $_fqdn
Hostname: $_hostname
TimeZone: $_tz
------------------------------------------------------------------------------------------

EOF
    else
        cat >> /root/$SCRIPTNAME.log <<- EOF
$runScriptDate
Arguments: $ARGS
------------------------------------------------------------------------------------------
SSH Port: $_sshport
FQDN: $_fqdn
Hostname: $_hostname
TimeZone: $_tz
------------------------------------------------------------------------------------------

EOF
    fi

    chmod 400 /root/$SCRIPTNAME.log
    str=`sed -n "/^${runScriptDate}$/,$ p" /root/$SCRIPTNAME.log`
    echo -e "\033[31m${str}\033[0m"
}

main(){
    getArguments
    setDefaultVariables
    setGlobalVariables
    updateOS
    setHostname
    setProfile
    setTimezone
    createUser
    setSSHD
    setFirewall
    printInfo
}

main
