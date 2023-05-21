# Ubuntu Configure guide
## 0. mkdir ~/usr/bin
## 更换源
    sudo vi /etc/apt/sources.list
    文件最前面添加：
    ##中科大源
    deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
    deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
    deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
    deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
    deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
    deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
    deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
    deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
    deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
    deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
    sudo apt-get update
    sudo apt-get upgrade
## Windows时间同步
    sudo apt-get install ntpdate
    sudo ntpdate time.windows.com
    sudo hwclock --localtime --systohc
## 美化
    sudo apt-get update
    sudo apt-get install gnome-tweak-tool
    sudo apt-get install gnome-shell-extensions
    启动程序
    开启Emacs输入
    字体全部选10
## 安装Typora
    https://www.typora.io/#linux
## 安装electron-ssr
    先安装python3
    sudo ln -s /usr/bin/python3 /bin/python
    sudo apt install libcanberra-gtk-module
    * deb安装
        https://github.com/qingshuisiyuan/electron-ssr-backup/releases
    * 手动安装
        将程序移至~/usr/bin
        cd ~/usr/bin
        chmod +x ssr-linux.AppImage
        右键运行、安装
## proxychains4
    sudo apt install proxychains4
    vi /etc/proxychains.conf
        socks5  127.0.0.1 1087 # 在最后删除原有的并添加此行
    vi /etc/profile
        alias pc="proxychains4 -q"
## 删除无效图标
    看/usr/share/applications下是否有xxx.desktop
    可以到～/.local/share/applications下看是否有xxx.desktop
## 常用工具
    sudo apt-get install git curl wget proxycharins4 gcc g++ clang gdb cmake make net-tools
## 输入法切换
    键盘快捷键－打字－切换至下个输入源－设置为ctrl-space
## ~/ 英文目录
    STEP1: 将这些目录修改为英文名，如：mv 桌面 Desktop
    STEP2: 修改配置文件  ～/.config/user-dirs.dirs ，将对应的路径改为英文名（要和STEP1中修改的英文名对应）
    vim ~/.config/user-dirs.dirs
    配置文件修改后的内容如下：
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Shared"
    XDG_DOCUMENTS_DIR="$HOME/Documents"
    XDG_MUSIC_DIR="$HOME/Musics"
    XDG_PICTURES_DIR="$HOME/Pictures"
    XDG_VIDEOS_DIR="$HOME/Videos"
## 安装完整版vim
    sudo apt-get remove vim-common
    sudo apt-get install vim
    sudo vi ~/.bashrc
        alias vi=vim
        alias sudo='sudo ' # 看清楚 sudo 后面有个空格
    vi /etc/vimrc
        内容如下：
        set nu
        syntax on
        set shiftwidth=4
        set tabstop=4
        set autoindent
        set expandtab
        set softtabstop=4
        set hlsearce
## 开发库
    sudo apt-get install libboost-all-dev
## 安装独显驱动
    https://blog.csdn.net/Yan_Chou/article/details/72847943
## TIM
    https://www.lulinux.com/archives/1319
## 网易云音乐
    https://music.163.com/#/download
## clion
    先安装jdk，官网下载deb包
    设置JAVA_PATH:
    sudo vi /etc/profile
        export JAVA_HOME=/usr/lib/jvm/jdk-13.0.2
        export JRE_HOME=$JAVA_HOME/jre
        export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
        export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
    https://www.jetbrains.com/clion/download/download-thanks.html?platform=linux
    解压至/opt
    破解
    汉化 https://github.com/pingfangx/jetbrains-in-chinese/tree/master/CLion
