0. mkdir ~/usr/bin
1. Windows时间同步
    sudo apt-get install ntpdate
    sudo nptdate time.windows.com
    sudo hwclock --localtime --systohc
2. 美化
    sudo apt-get update
    sudo apt-get install gnome-tweak-tool
    sudo apt-get install gnome-shell-extensions
    启动程序
    开启Emacs输入
    字体全部选10
3. 安装Typora
    https://www.typora.io/#linux
4. 安装electron-ssr
    先安装python3
    sudo ln -s /usr/bin/python3 /bin/python
    sudo apt install libcanberra-gtk-module
    将程序移至~/usr/bin
    cd ~/usr/bin
    chmod +x ssr-linux.AppImage
    右键运行、安装
    定阅、更新pac
5. 删除无效图标
    看/usr/share/applications下是否有xxx.desktop
    可以到～/.local/share/applications下看是否有xxx.desktop
5. 常用工具
    sudo apt-get install git curl wget proxycharins4 gcc g++ clang 
6. ~/ 英文目录
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
7. 安装完整版vim
    sudo apt-get remove vim-common
    sudo apt-get isntall vim
    sudo echo "# add by manyy" >> /etc/profile
    sudo echo "alias vi=vim" >> /etc/profile
    vi /etc/vimrc
    内容如下：
    set nu
    syntax on
    set shiftwidth=4
    set tabstop=4
    set autoindent
    set expandtab
    set softabstop=4
    set hlsearch
8. 更换源
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
