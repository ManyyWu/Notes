::chcp 65001 设置编码，防止中文乱码
chcp 65001

@echo off

rem ----邮件主题----
set title="[Startup]%date%  %time%  %computername%  %username%"
rem ----邮件内容-----
set body="Startup"
rem ----收件邮箱-----
set receiver=openkt@outlook.com
rem ----发件邮箱-----
set sender=273526061@qq.com
rem ----邮箱秘钥-----
set code=ltxzhbzwydnrbige
rem ----执行发送-----
C:\Bin\blat.exe -body %body% -s %title% -t %receiver% -server smtp.qq.com -f %sender% -u %sender% -pw %code%
