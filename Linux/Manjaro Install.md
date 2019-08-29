# Manjaro Install
## 更换国内源
    sudo pacman -Syy
    sudo pacman-mirrors -i -c China -m rank
    sudo pacman -Syy
## 安装vim
    sudo pacman -S lib32-glibc glibc vim
    sudo vi /etc/vimrc
        " add by manyy 
        set nu
        syntax on
        set shiftwidth=4
        set tabstop=4
        set autoindent
        set expandtab
        set softtabstop=4
        set hlsearch 
    sudo vi ~/.bashrc # for all users
        # vim 
        alias vi=vim
        alias sudo='sudo ' # 看清楚 sudo 后面有个空格
        source/etc/profile
## 更换arch国内源
    sudo vim /etc/pacman.conf
        [archlinuxcn]
        SigLevel = Optional TrustedOnly
        Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
        sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
## 安装fcitx 
    sudo pacman -S python-gobject fcitx kcm-fcitx fcitx-im fcitx-configtool
    vim /etc/.xprofile
        # fcitx
        export XIM_PROGRAM=fcitx
        export XIM=fcitx
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export XMODIFIERS="@im=fcitx"
    # 关闭自动上屏
    vi /usr/share/fcitx/table/wbx.conf
        AutoSend=0
    source /etc/.xprofile
    fcitx
    reboot
## 安装常用软件
    sudo pacman -S cmake make gcc git wget curl net-tools dnsutils inetutils iproute2 clang
    sudo pacman -S google-chrome netease-cloud-music deepin.com.qq.im
    sudo pacman -S proxychains
    # 配置proxychains
    sudo vi /etc/proxychainsx.conf 
        socks5 127.0.0.1 1081
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
    # 设置蓝牙传输路径(xfce)
    blueman-services
    传输-Incoming Folder设置为新目录
## 常用开发库
## 时间不同步
    timedatectl set-local-rtc 1 --adjust-system-clocK
## 安装Typora
    https://www.typora.io/#linux
## 安装Clion
    sudo pacman -S clion
    # 汉化、破解见安装包
## 删除无效图标
    看/usr/share/applications下是否有xxx.desktop
    可以到～/.local/share/applications下看是否有xxx.desktop
## 显卡
    先备份系统
## electron-ssr安装
    将electron-ssr.AppImage复制到~/Usr/bin/
    右键执行,定阅
    添加启动项，命令"home/manyy/Usr/bin/ssr/electron-ssr-0.2.3-x86_64.AppImage" %U
    gnome添加托盘图标
    sudo pacman -S libappindicator-sharp libappindicator-gtk3
    无法运行：libicuuc.so.64问题, 更新系统
    sudo pacman -Syy && sudo pacman -Syu
## 快捷键(xfce)
    exo-open --launch TerminalEmulator C-A-T
    exo-open --launch FileManager      C-A-F

## emacs 支持
    emacs
