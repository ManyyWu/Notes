## 
    sudo pacman -Syy
    sudo pacman-mirrors -i -c China -m -rank
    sudo pacman -Syy
##
    sudo pacman -S lib32-glibc glibc vim
    sudo pacman -S cmake make gcc 
##
    emacs
## ibus
    sudo pacman -S python-gobject ibus ibus-table 
    wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ibus/ibus-table-chinese-1.4.5-Source.tar.gz  
    tar -zxvf ibus-table-chinese-1.4.5-Source.tar.gz
    cd -zxvf ibus-table-chinese-1.4.5-Source
    cmake . && make && sudo make install
    vim /etc/.bashrc
    ibus-setup
