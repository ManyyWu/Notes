# Redis
## 服务
    * 查看进程  
      $ps -aux | grep redis
    * 查看网络状态  
      $netstat -nlt | grep 6379
    * 查看服务器状态  
      $sudo /etc/init.d/redis-server status  
      $systemctl status redis  
    * 通过命令行客户端访问Redis  
      $redis-cli
