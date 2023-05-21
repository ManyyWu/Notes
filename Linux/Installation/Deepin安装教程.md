# Deepin Install
## 安装vim
1. $sudo apt install vim
2. $sudo vim /etc/vim/vimrc
```
" add by manyy 
set nu
syntax on
set shiftwidth=4
set tabstop=4
set autoindent
set expandtab
set softtabstop=4
set hlsearch 
```
3. $vi ~/.bashrc # for all users
```
alias vi=vim
alias sudo='sudo ' # 看清楚 sudo 后面有个空格
source/etc/profile
```
## 安装常用软件
* 工具 
  * $sudo apt install git curl wget gcc g++ cmake make
* proxychains4
  1. $sudo apt install proxychains4
  2. $sudo vi /etc/proxychains4.conf
  ```
  socks5 127.0.0.1 1081 # 在最后删除原有的并添加此行
  ```
* electron-ssr
  1. 将electron-ssr.AppImage复制到~/Usr/bin/，添加执行权限
  2. 右键执行，定阅，设置http代理端口1087，socks5代理端口1081，PAC代理，更新PAC
  3. 网络设置-系统代理-自动代理，配置URL设置为http://127.0.0.1:2333/proxy.pac
  4. $vi ~/.config/autostart/electron-ssr.desktop #添加启动项
  ```
  Exec="~/Usr/bin/ssr/electron-ssr-0.2.3-x86_64.AppImage" %U
  ```
* Clion2019
  安装、汉化、破解见安装包
* 其他软件（软件商店）
  Typora
  TIM
  微信
  网易云音乐
  chrome
  企业微信
  Wireshark
## 安装常用开发库
* boost
```
$sudo apt install libboost-dev
```
## 输入法
* 五笔取消自动上屏
  1. $vi /usr/share/fcitx/table/wbx.conf
  ```
  AutoSend=0
  ```
## 显卡驱动
1. Deepin显卡驱动管理器中安装
2. sudo apt-get install mesa-utils #检查驱动是否安装成功 注解：安装mesa-utils这个包，用来显示系统的glx相关信息。
3. optirun glxinfo|grep NVIDIA #注解：用optirun调用独显输出系统的glxinfo来查看驱动是否安装成功。如果打开nvidia-settings时提示“You do not appear to be using the NVIDIA X driver”,在terminal中运行如下命令optirun -b none nvidia-settings -c :8
4. $optirun glxgears -info #测试 Bumblebee 是否支持你的 Optimus 系统
如果在终端中看到一个关于你的 Nvidia 的提示，恭喜你，Bumblebee 和 Optimus 已经开始工作了。Bumblebee并不能做到集显(Intel显卡)和独显(NVIDIA显卡)之间的自动切换。
5. $optirun 程序 #使用bumblebeek开启独立显卡运行程序
## 蓝牙
使用如下命令查看蓝牙是否被某个软件或者系统给禁用了
```
sudo rfkill list
sudo rfkill unblock bluetooth
```
