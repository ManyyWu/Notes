# Get Linux sources

## Ubuntu、Deepin
    $sudo vi /etc/apt/sources.list
    添加
    deb-src http://packages.deepin.com/deepin lion main contrib non-free
    $sudo apt-get update
    $which ls # 获取命令所在路径
    $dpkg -S PATH
    $sudo apt-get source 软件包
    源代码将会下载到当前路径
