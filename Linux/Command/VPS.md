## 软件
  * nmon

## 配置
  * ubuntu关闭`Pending kernel upgrade`提示
      sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

## 安全
### iptables
  * 查看规则: sudo iptables -L -n --line-numbers
  * 配置:
  /etc/iptables/rules.v4
  ```
  # 清除已有iptables规则
  iptables -F
  # 允许本地回环接口(即运行本机访问本机)
  iptables -A INPUT -i lo -j ACCEPT
  # 允许已建立的或相关连的通行
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  # 允许所有本机向外的访问
  iptables -A OUTPUT -j ACCEPT
  # 允许访问22端口，以下几条相同，分别是22,80,443端口的访问
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  # 如果有其他端口的话，规则也类似，稍微修改上述语句就行
  # 允许ping
  iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
  # 禁止其他未允许的规则访问
  iptables -A INPUT -j REJECT
  iptables -A FORWARD -j REJECT
  ```
  * iptables-restore < /etc/iptables/rules.v4
  * echo '#!/bin/bash' > /etc/network/if-pre-up.d/iptables ; echo 'iptables-restore < /etc/iptables/rules.v4' >> /etc/network/if-pre-up.d/iptables
  * chmod +x /etc/network/if-pre-up.d/iptables
