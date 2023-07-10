# VBOX

## Windows
### 列出所有安装的虚拟机
  VBoxManage list vms
### 后台打开，无界面
  VBoxManage startvm $NAME --type headless 
### gui方式启动，跟桌面点击没有区别
  VBoxManage startvm $NAME --type gui
### 列出运行中的虚拟机
  VBoxManage list runningvms
### 关闭虚拟机，等价于点击系统关闭按钮，正常关机
  VBoxManage controlvm $NAME acpipowerbutton
### 关闭虚拟机，等价于直接关闭电源，非正常关机
  VBoxManage controlvm $NAME poweroff
### 暂停虚拟机的运行
  VBoxManage controlvm $NAME pause
### 恢复暂停的虚拟机
  VBoxManage controlvm $NAME resume
### 保存当前虚拟机的运行状态
  VBoxManage controlvm $NAME savestate
