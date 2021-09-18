#!/usr/bin/env bash
# Author: info@yanyong.cc
set -e
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPTNAME="${0##*/}"
ARGS="$*"
shopt -s extglob


usage(){
    echo "Usage: /PATH/SCRIPTNAME [[--]fqdn=FQDN] [[--]port=PORT] [ [--]user=USERNAME [[--]passwd=PASSWORD] [[--]keyPasswd=PASSWORD] ] [[--]source={cn|CN|hk|HK|us|US|ali|ALI|aws|AWS}] [[--]tz={Asia/Shanghai|...}] [[--]{distupgrade|fullupgrade}] [[--]help]"
}

setCN(){
    mirror=http://mirrors.ustc.edu.cn/debian/
    security=http://mirrors.ustc.edu.cn/debian-security
    ntp='0.cn.pool.ntp.org 1.cn.pool.ntp.org 2.cn.pool.ntp.org 3.cn.pool.ntp.org'
}
setHK(){
    mirror=http://ftp.hk.debian.org/debian/
    #security=http://ftp.hk.debian.org/debian-security
    security=http://security.debian.org/debian-security
    ntp='0.hk.pool.ntp.org 1.hk.pool.ntp.org 2.hk.pool.ntp.org 3.hk.pool.ntp.org'
}
setUS(){
    mirror=http://ftp.us.debian.org/debian/
    security=http://security.debian.org/debian-security
    ntp='0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org'
}
setALI(){
    mirror=http://mirrors.aliyun.com/debian/
    security=http://mirrors.aliyun.com/debian-security/  # must .../debian-security/ 
    ntp='0.cn.pool.ntp.org 1.cn.pool.ntp.org 2.cn.pool.ntp.org 3.cn.pool.ntp.org'
}
setAWS(){
    mirror=http://cdn-aws.deb.debian.org/debian/
    security=http://security.debian.org/debian-security
    ntp='0.amazon.pool.ntp.org 1.amazon.pool.ntp.org 2.amazon.pool.ntp.org 3.amazon.pool.ntp.org'
}

getArguments(){
#https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
for i in $ARGS; do
    case $i in
        #--fqdn=?*|fqdn=?*)
        ?(--)fqdn=?*.?*.?*)
            eval ${i#--}
            ;;
        #--port=?*|port=?*)
        ?(--)port=[1-9]+([0-9]))  # >= 10
            eval ${i#--}
            ;;
        #--user=?*|user=?*)
        ?(--)user=[a-z]*([-0-9a-z_]))  # 用户名规则参考文件/etc/adduser.conf
            eval ${i#--}
            ;;
        --passwd=?*|passwd=?*)
            eval ${i#--}
            ;;
        --keyPasswd=?*|keyPasswd=?*)
            eval ${i#--}
            ;;
        #--source=?*|source=?*)
        ?(--)source=@(cn|CN)|?(--)source=@(hk|HK)|?(--)source=@(us|US)|?(--)source=@(ali|ALI)|?(--)source=@(aws|AWS))
            eval ${i#--}
            { [[ $source = cn || $source = CN ]] && setCN; } || \
            { [[ $source = hk || $source = HK ]] && setHK; } || \
            { [[ $source = us || $source = US ]] && setUS; } || \
            { [[ $source = ali || $source = ALI ]] && setALI; } || \
            { [[ $source = aws || $source = AWS ]] && setAWS; }
            ;;
        #--tz=?*|tz=?*)
        ?(--)tz=[A-Z]+([a-z])/[A-Z]+([a-z])|?(--)tz=UTC)
            eval ${i#--}
            tzlist=(`timedatectl list-timezones`)
            for j in ${tzlist[*]}; do
                if [[ $tz = $j ]]; then inlist=true; fi
            done
            if [[ $inlist != true ]]; then usage; exit 2; fi
            ;;
        #--distupgrade|distupgrade|--fullupgrade|fullupgrade)
        ?(--)@(distupgrade|fullupgrade))
            distupgrade=true
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
    #full_domain="${fqdn:-www.example.com}"
    full_domain="${fqdn}"
    my_hostname=${full_domain%%.*}
    my_ip=`hostname -I | awk '{print $1}'`
    checkPort=`awk '/^Port/{print $2}' /etc/ssh/sshd_config`
    current_port="${checkPort:-22}"
    ssh_port="${port}"
    #new_user="${user:-example}"
    new_user="${user}"
    password16="${passwd:-`tr -dc '[:alnum:]' < /dev/urandom | head -c 16`}"
    password8="${keyPasswd:-`tr -dc '[:digit:][:lower:]' < /dev/urandom | head -c 8`}"
    #debian_mirror="${mirror:-http://mirrors.ustc.edu.cn/debian/}"
    #debian_security="${security:-http://mirrors.ustc.edu.cn/debian-security}"
    #ntp_servers="${ntp:-0.cn.pool.ntp.org 1.cn.pool.ntp.org 2.cn.pool.ntp.org 3.cn.pool.ntp.org}"
    debian_mirror="${mirror}"
    debian_security="${security}"
    ntp_servers="${ntp}"
    #time_zone="${tz:-Asia/Shanghai}"
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
    _source="${debian_mirror}"
    _source_security="${debian_security}"
    _ntp="${ntp_servers}"
    _tz="${time_zone}"
}

updateOS(){
  if [[ -n $_source ]]; then
      if [[ ! -f /etc/apt/sources.list.origin ]]; then cp /etc/apt/sources.list{,.origin}; fi
      cat > /etc/apt/sources.list <<- EOF
deb $_source buster main
deb-src $_source  buster main
deb $_source_security buster/updates main
deb-src $_source_security buster/updates main
deb $_source buster-updates main
deb-src $_source buster-updates main
EOF

      sed -ri 's/^#?(NTP=).*$/\1'"$_ntp"'/' /etc/systemd/timesyncd.conf  # 直接替换，懒得各种判断
      systemctl restart systemd-timesyncd
  fi

  #apt-get update && apt-get -y upgrade
  apt update

  #-o Dpkg::Options::=--force-confnew  # 不建议使用

  DEBIAN_FRONTEND=noninteractive apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  upgrade

  if [[ $distupgrade = true ]]; then
      DEBIAN_FRONTEND=noninteractive apt-get \
      -o Dpkg::Options::=--force-confold \
      -o Dpkg::Options::=--force-confdef \
      -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
      dist-upgrade
  fi

  apt-get -y install man sudo vim net-tools
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
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias lt='ls -alt --color=auto'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
umask 022
export TMOUT=3600
EOF

fi
}

setTimezone(){
  if [[ -n $_tz ]]; then
    timedatectl set-timezone $_tz
    #sed -ri 's/^#+(NTP=).*$/\1'"$_ntp"'/' /etc/systemd/timesyncd.conf
    #systemctl restart systemd-timesyncd
  fi
}

createUser(){
  if [[ ! $createuser = false ]]; then
    if ! id -u $_user &> /dev/null; then
        iscreate=true
        useradd -m $_user -s /bin/bash
        eval chpasswd <<< "$_user:$_password"
        usermod -aG sudo $_user

        if [[ ! -f /etc/sudoers.d/nopasswd ]]; then
            echo -e '%sudo\tALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopasswd
        fi

        mkdir /home/$_user/.ssh
        chown $_user:$_user /home/$_user/.ssh
        chmod 700 /home/$_user/.ssh
        su - $_user -c "ssh-keygen -qf /home/$_user/.ssh/id_rsa.$_user -t rsa -N $_passwd_key"
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

setSSH(){
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

    systemctl reload ssh
}

setIptables(){
    echo 'iptables-persistent iptables-persistent/autosave_v4 boolean true' | debconf-set-selections
    echo 'iptables-persistent iptables-persistent/autosave_v6 boolean false' | debconf-set-selections
    apt-get -y install iptables-persistent

    if ! iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT &> /dev/null; then iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT; fi
    if ! iptables -C INPUT -i lo -j ACCEPT &> /dev/null; then iptables -A INPUT -i lo -j ACCEPT; fi
    if ! iptables -C INPUT -p icmp -m state --state NEW --icmp-type echo-request -j ACCEPT &> /dev/null; then iptables -A INPUT -p icmp -m state --state NEW --icmp-type echo-request -j ACCEPT; fi

    if [[ -n $_sshport ]]; then  # 如果指定ssh端口
        if [[ ! $_sshport = $_currentport ]]; then  # 如果端口不一致，删除当前规则，添加新规则
          if iptables -C INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT &> /dev/null; then iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT; fi
          if ! iptables -C INPUT -p tcp -m state --state NEW -m tcp --dport "$_sshport" -j ACCEPT &> /dev/null; then iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport "$_sshport" -j ACCEPT; fi
        else  # 如果端口一致，检测是否有防火墙规则，无则添加
          if ! iptables -C INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT &> /dev/null; then iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT; fi
        fi
    else  # 如果不指定ssh端口，检测是否有防火墙规则，无则添加
        if ! iptables -C INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT &> /dev/null; then iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport "$_currentport" -j ACCEPT; fi
    fi

    if ! iptables -C INPUT -p tcp -m state --state NEW -m multiport --dports http,https -j ACCEPT &> /dev/null; then iptables -A INPUT -p tcp -m state --state NEW -m multiport --dports http,https -j ACCEPT; fi

    iptables -P INPUT DROP

    netfilter-persistent save
    if [[ ! -f /etc/iptables/rules.v4.origin ]]; then cp /etc/iptables/rules.v4{,.origin}; fi
    #iptables-restore < /etc/iptables/rules.v4.origin  # run the script multiple times
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
APT Source: $_source
TimeZone: $_tz
NTP: $_ntp
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
APT Source: $_source
TimeZone: $_tz
NTP: $_ntp
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
    setSSH
    setIptables
    printInfo
}

main
