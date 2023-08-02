# SSH

## ssh断开不终止程序
    * $nohup command > out.txt &
    * $(command > out.txt &)
    
## ssh使用密码登录
    * $sshpass -p passwd ssh -p port user@hostname
    * $sshpass -p passwd scp -P port -r user@hostname:remote local
    
# 去除yes/no提示
    * scp -o "StrictHostKeyChecking no" user@hostname:filename
    * ssh -o "StrictHostKeyChecking no" user@hostname
    
## ssh免密
    * ~/.ssh/config
    ```
    Host name
    HostName hostname
    User user
    Port port
    IdentityFile ~/.ssh/id_rsa
    ```
    * client$ ssh-keygen -t rsa -C "邮件"
    * cat ~/.ssh/id_rsa.pub
    * target# vi /etc/ssh/sshd_config
        PasswordAuthentication yes
        RSAAuthentication yes # 这个参数可能没有 没关系
        PubkeyAuthentication yes
        AuthorizedKeysFile .ssh/authorized_keys
    * ssh-copy-id -i ~/.ssh/id_rsa.pub host
    * target$ chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys
    

## 跳转
  ~/.ssh/config
  ```
  Host *
      ServerAliveInterval 10
      TCPKeepAlive yes
      HostKeyAlgorithms +ssh-rsa,ssh-dss
  
  Host jump
      HostName 跳服IP
      User k
      Port 22
  
  Host name # 可使用通配符
      HostName 目标服IP
      Port 22
      User user00
      ProxyCommand ssh -q -W %h:%p jump
  ```
  或  
  ```$ssh username@目标服IP -p 22 -o ProxyCommand='ssh -p 22 username@跳服IP -W %h:%p'```
