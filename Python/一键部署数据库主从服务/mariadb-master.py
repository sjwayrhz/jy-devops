import pexpect
import os
import configparser

# HOSTNAME_DB1='db1'
# HOSTNAME_DB2='db2'
# DB1 = '192.168.254.24'
# DB2 = '192.168.254.27'
DBPASSWORD = '1'

def repo():
    os.system('touch /etc/yum.repos.d/mariadb.repo')
    with open('/etc/yum.repos.d/mariadb.repo','w',encoding='utf8') as f:
        f.write('[mariadb]')
    config = configparser.ConfigParser()
    config.read("/etc/yum.repos.d/mariadb.repo", encoding="utf-8")
    config.set('mariadb', 'name', 'MariaDB')
    config.set('mariadb', 'baseurl', 'http://mirrors.ustc.edu.cn/mariadb/yum/10.3/centos7-amd64/')
    config.set('mariadb', 'gpgkey', 'http://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB')
    config.set('mariadb', 'gpgcheck', '1')
    config.write(open('/etc/yum.repos.d/mariadb.repo','w'))
def mariadb():
    a = os.system('yum install MariaDB -y &> /dev/null')
    if a == 0:
        b = os.system('systemctl start mariadb &> /dev/null')
        if b == 0:
            print('mariadb启动成功')
        child = pexpect.spawn('mysql_secure_installation')
        child.expect('enter for none')
        child.sendline('')
        child.expect('Y/n')
        child.sendline('y')
        child.expect('New')
        child.sendline(DBPASSWORD)
        child.expect('Re-enter')
        child.sendline(DBPASSWORD)
        child.expect('successfully')
        child.sendline('')
        child.sendline('')
        child.sendline('')
        child.sendline('')
        child.interact()
        child.close()
def db1():
    config = configparser.ConfigParser()
    config.read("/etc/my.cnf.d/server.cnf", encoding="utf-8")
    config.set('mysqld', 'server-id', '1')
    config.set('mysqld', 'log-bin', 'mysql-bin')
    config.write(open('/etc/my.cnf.d/server.cnf','w'))
    b = os.system('systemctl restart mariadb')
    if b ==  0:
        # os.system('mysql -uroot -p%s' % DBPASSWORD)
        # os.system("CREATE USER 'slave'@'%' IDENTIFIED BY 'slave';")
        # os.system("GRANT REPLICATION SLAVE ON *.* TO 'slave'@'%';")
        # os.system('flush privileges;')
        # os.system('show master status')
        child = pexpect.spawn('mysql -uroot -p1')
        child.expect('none')
        child.sendline("CREATE USER 'slave'@'%' IDENTIFIED BY 'slave';")
        child.expect('none')
        child.sendline("GRANT REPLICATION SLAVE ON *.* TO 'slave'@'%';")
        child.expect('none')
        child.sendline('flush privileges;')
        child.expect('none')
        child.sendline('show master status;')
        child.interact()
        child.close()
def main():
    repo()
    mariadb()
    db1()
if __name__ == '__main__':
    main()