# Manjaro Install
## 断网
## 更换国内源
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
## 更换arch国内源
    sudo vim /etc/pacman.conf
        [archlinuxcn]
        SigLevel = Optional TrustedOnly
        Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
    sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
## 安装fcitx 
    sudo pacman -S python-gobject fcitx kcm-fcitx fcitx-im fcitx-configtool
    /etc/.xprofile ~/.xprofile 加上
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
    sudo pacman -S cmake make gcc git wget curl net-tools dnsutils inetutils iproute2 clang gdb zip unzip net-tools
    sudo pacman -S google-chrome 
    sudo pacman -S netease-cloud-music 
    sudo pacman -S gnome-settings-daemon deepin.com.qq.office
    安装好的TIM打不开：如果是Arch系KDE/Plasma桌面，先安装gnome-settings-daemon，然后将/usr/lib/gsd-xsettings设置为自动启动
        qq显示图标
        tweaks-扩展-勾选user theme
    kde安装time: https://www.lulinux.com/archives/1319
    sudo pacman -S clion
        下载一下中文字体
        sudo pacman -S wqy-microhei
        clion先设置一个中文字体，复制中文即可显示中文且不乱码
    sudo pacman -S gnome-tweaks
        设置启动项
        开启Emacs输入
        字体全部选10
        扩展－取消Dash to dock，勾选Dash to panel, 勾选Arc menu, 勾选Desktop icons
    sudo pacman -S proxychains
    # 配置proxychains
    sudo vi /etc/proxychains.conf 
        socks5 127.0.0.1 1081
    sudo pacman -S ntfs-3g # arch 默认只读挂载
        关闭Windows快速启动
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
    sudo timedatectl set-local-rtc true
## 安装Typora
    https://www.typora.io/#linux
## 安装Clion
    sudo pacman -S jdk clion
    sudo pacman -S clion-gdb
    # 破解见安装包
        汉化 https://github.com/pingfangx/jetbrains-in-chinese/tree/master/CLion
## 删除无效图标
    看/usr/share/applications下是否有xxx.desktop
    可以到～/.local/share/applications下看是否有xxx.desktop
## 显卡
    先备份系统
## electron-ssr安装
    将electron-ssr.AppImage复制到~/Usr/bin/，添加执行权限
    右键执行,定阅
    添加启动项，命令"/home/manyy/Usr/bin/ssr/electron-ssr-0.2.3-x86_64.AppImage" %U
    gnome添加托盘图标
    sudo pacman -S libappindicator-sharp libappindicator-gtk3
    无法运行：libicuuc.so.64问题, 更新系统
    sudo pacman -Syy && sudo pacman -Syu
    * PAC代理
    http://127.0.0.1:2333/proxy.pac
## 快捷键(xfce)
    exo-open --launch TerminalEmulator C-A-T
    exo-open --launch FileManager      C-A-F
## 快捷键(gnome)
    gnome-terminal C-A-T
## proxy(kde)
    系统代理只设置socks5，或使用SwitchOmega，只设置socks5
## For TRIM
    sudo systemctl enable fstrim.timer
    sudo systemctl start fstrim.timer
## Others
### chrome设置默认浏览器
    将html默认打开方式设置为chrome
