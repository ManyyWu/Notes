1. 将 10007 设为排除范围，管理员权限打开PowerShell：
```PowerShell
net stop winnat
netsh int ipv4 add excludedportrange protocol=tcp startport=10007 numberofports=1
net start winnat
```

2. 检查是否生效，10007带`*`号则表示已被排除：
```PowerShell
netsh int ipv4 show excludedportrange protocol=tcp
```
