## Vim Notes
    W                = 跳转到下一个字符串首部
    E/B              = 向前/向后跳转一个字符串的首部/尾部
    s                = xi
    C                = c$ 修改到行尾
    S                = 0c$ 修改一整行
    D                = d$ 删除到行尾
    Y                = yy
    A                = $a
    I                = 0i
    cw               = 修改一个词
    cc               = S
    
    fx               = 查找下一个x
    Fx               = 查找上一个x
    vfx/zfx          = 选择/删除至下一个x
    *                = 向下搜索光标所在单词
    %                = 跳转到匹配的括号、注释、宏块
    [m               = 向下查找大括号
    ]m               = 向上查找大括号
    
    d/word           = 删至下一个word前
    d?word           = 删至上一个word前
    
    bve/evb          = 选择光标处单词
    BvE/EvB          = 选择光标处字符串
    ve/vb            = 选择当前光标开始的单词
    vE/vB            = 选择当前光标开始的字符串
    
    U                = 撤销当前行所有操作
    
    di['"{([<wW]     = 删除配对标点内内容             w表示单词 W表示字符串
    yi['"{([<wW]     = 复制配对标点内内容
    vi['"{([<wW]     = 选择配对标点内内容
    da['"{([<wW]     = 删除配对标点内内容(包括标点)
    ya['"{([<wW]     = 复制配对标点内内容(包括标点)
    va['"{([<wW]     = 选择配对标点内内容(包括标点)
    
    zz               = 光标所在行移动到屏幕中央
    c-y              = 向下滚动一行(光标不移动)
    c-e              = 向上滚动一行(光标不移动)
    c-d              = 向下滚半屏
    c-u              = 向上滚半屏
    c-f              = 上一页
    c-b              = 下一页
    c-o              = 后退
    c-i              = 前进
    H/M/L            = 跳转到当前屏首行、中间、尾行
    zh/zl            = 向左/右滚动               
    
    gd               = 跳转到单词首次出现行
    c-t              = 退栈(返回上一个函数, 比c-o更快)
    gh               = 查看光标所在处错误信息
    gb               = 找出与光标下相同的下一个单词, 并添加一个光标 ，接下来就可以同时修改
    [c-d             = 跳转到宏定义行
    [c-i             = 跳转到函数、变量定义行
    
    /                = 向下查找
    ?                = 向上查找
    
    ~                = 转换大小写
    .                = 重复刚才的操作
    
    =                = 格式化所选内容
    ==               = 格式化当前行
    gg=G             = 全文格式化
    
    mx               = 标记x [a-zA-Z]
    :marks           = 列举所有标记
    :delmarks a b c  = 删除标记a b c
    :delmarks!       = 删除所有标记
    
    "+yy             = 复制到系统剪切板
    "+p              = 从系统剪切板粘贴
    
    ~                = 选择内容切换大小写
    U/u              = 选择内容切换成大/小写
    
    替换:
    :[range]s/pattern/string/[flags]
    range:
    %                = 整个文件
    .                = 当前行
    $                = 最后一行
    N                = 行号
    'x               = 标记x所在行
    range,range      = 范围
    range-N          = range-N行
    range+N          = range+N行
    range-N, range+N = 范围
    flags:
    g                = 指定范围
    c                = 需要确认(y/n)
    i                = 不区分大小写
    
    insert模式下:
    c-p/c-n          = 补全, c-h删除 c-d取消
    c-xl             = 整行补全
    c-xf             = 文件名补全
    c-xd             = 宏定义补全
    c-xv             = vim命令补全
    
    zf10j            = 向下折叠10行
    zf10k            = 向上折叠10行
    zf               = 折叠所选行
    zd               = 删除折叠
    zD               = 删除嵌套折叠
    zE               = 删除所有折叠
    zo               = 打开当前折叠
    zc               = 关闭当前折叠
    zm               = 关闭所有折叠
    zM               = 关闭所有嵌套折叠
    zr               = 打开所有折叠
    zR               = 打开所有嵌套折叠
    zn               = 禁用折叠
    zN               = 启用折叠
    
    c-wv             = vs [file]
    c-ws             = sp [file]
    vs [file]        = 纵向分割窗口
    sp [file]        = 横向分割窗口
    c-w[hjkl]        = 跳转窗口
    c-ww             = 移动到下一个窗口
    c-w10<           = 窗口宽度缩小10格
    c-w10>           = 窗口宽度增加10格
    c-w10-           = 窗口高度缩小10格
    c-w10=           = 窗口高度增加10格
    c-wT             = 移动到新tab
    windo            = 所有窗口执行命令
    
    :tabs            = 查看所有tab
    :tabnew file     = 新tab
    :tabe file       = 当前tab打开file
    :tabn            = 切换到下一个tab
    :tabp            = 切换到上一个tab
    gt               = 切换到上一个tab
    gT               = 切换到下一个tab
    1gt              = 切换到第一个tab
    :tabm 0-n        = 移动tab
    :tabdo cmd       = 所有tab执行命令
    
    :ls              = 列出所有buffer
    :bn              = 切换到下一个buffer
    :bp              = 切换到上一个buffer
    :b 0-n           = 切换到指定buffer
    :sb 0-n          = 水平分屏并打开指定buffer
    :vertical sb 0-n = 垂直分屏并打开指定buffer
    
    gf               = 编辑光标下的文件
    c-^              = 切换轮换文件
    :find            = 当前工作目录查找并找开文件
    :cd path         = 切换工作目录
    :pwd             = 显示当前工作目录
    :file            = 显示文件名
    :file newfile    = 置当前文件名为newfile
    :files           = 显示文件名
    
    :e path          = 当前tab打开path
    
    $vimdiff f1 f2   = 比较f1 f2
    
    :w file          = 另存为file
    :r file          = 读取file中数据到光标后
    :n1,n2 w file    = n1-n2行另存为file
    
    :mksession file  = 创建会话
    $vim -S file     = 打开会话
    
    十六进制修改
    $vim -b file
    :%!xxd           = 进入xxd模式
    :%!xxd -r        = 反向dump
    
    ga               = 显示光标下字符的ascii/十进制/十六进制/八进制
    
    :sh              = 启动外壳，退出后回到vim
    
    $vim -o/-O f f1  = 打开多个文件时横向/纵向分割

## ~/.vimrc
    " 显示行号
    set number
    " 高亮
    syntax on
    " 使用鼠标
    set mouse=a
    " 编码
    set encoding=utf-8
    " 256色
    set t_Co=256
    " 检查文件类型
    filetype indent on
    " tab显示空格数
    set tabstop=2
    " 自动保持缩进
    set autoindent
    " >>缩进空格数
    set shiftwidth=2
    " tab转化为空格
    set expandtab
    " tab 转化为多个空格
    set softtabstop=2
    " 光标所在行高亮
    set cursorline
    " 显示光标当前行行号
    set relativenumber
    " 匹配括号
    set showmatch
    " 高亮搜索
    set hlsearch
    " 自动跳转到匹配结果
    set incsearch
    " 共享剪切板
    set clipboard=unnamed
    " 不自动换行
    set nowrap
    
    " Ctags
    set autochdir
    set tags+=~/.vim/systags
    set tags+=tags;
    let mapleader=";"
    nmap <leader>n :tnext<CR>
    nmap <leader>p :tprevious<CR>

## Ctags
    MacOS默认使用XCode版本ctags
    $brew install ctags
    $sudo echo '\nalias ctags="/usr/local/bin/ctags"' >> /etc/profile
    $source /etc/profile

## ~/.vim/mksystags
    SYS_INC_DIR='/usr/include'
    USR_INC_DIR='/usr/local/include'
    EXT_INC_DIR=''
    
    if [ ! -d "$SYS_INC_DIR" ]; then
      SYS_INC_DIR=''
    fi
    if [ ! -d "$USR_INC_DIR" ]; then
      USR_INC_DIR=''
    fi
    
    if [ "$SYS_INC_DIR" != "" ]; then
      echo $SYS_INC_DIR
    fi
    if [ "$USR_INC_DIR" != "" ]; then
      echo $USR_INC_DIR
    fi
    if [ "$EXT_INC_DIR" != "" ]; then
      echo $EXT_INC_DIR
    fi
    
    if [[ "$SYS_INC_DIR" != "" || "$USR_INC_DIR" != "" || "$EXT_INC_DIR" != "" ]]; then
      ctags -I __THROW -I __attribute_pure__ -I __nonnull -I __attribute_ --langmap=c:+.h --languages=c,c++ --c++-kinds=+p+l+x+c+d+e+f+g+m+n+s+t+u+v --fields=+liaS --extra=+q --c-kinds=+p+l+x+c+d+e+f+g+m+n+s+t+u+v --fields=+liaS --extra=+q -R -f ~/.vim/systags $SYS_INC_DIR $USR_INC_DIR $EXT_INC_DIR && echo "Successed!" || echo "Failed!"
    else
      echo "No valid include direcories!"
    fi

## 正则表达式
```
:%s/\(abc\)\(.*\)\(xyz\)/\3\2\1/g
```

## 批量替换
```
:args *.txt
:argdo %s/abs/xyz/g | update
```

## ~/.vim/mktags
    if [ $# != 1 ]; then
      echo "Invalid arguments!"
    fi
    
    ctags -I __THROW -I __attribute_pure__ -I __nonnull -I __attribute_ --langmap=c:+.h --languages=c,c++ --c++-kinds=+p+l+x+c+d+e+f+g+m+n+s+t+u+v --fields=+liaS --extra=+q --c-kinds=+p+l+x+c+d+e+f+g+m+n+s+t+u+v --fields=+liaS --extra=+q -R -f $1/tags && echo "Successed!" || echo "Failed!"

## ctags标识符跳转
    g]               = 查看标识符跳转列表
    ;n               = 下一个跳转位置 nmap <leader>n :tnext<CR>
    ;p               = 上一个跳转位置 nmap <leader>p :tprevious<CR>

## 图解
![01-27-36-a8773912b31bb051e8d67c72367adab44bede0fe](https://user-images.githubusercontent.com/51533330/130655272-a32de7b2-baeb-4f32-96de-c396dcf2daf9.jpg)
![728da9773912b31b0bf9bc038c18367adab4e107](https://user-images.githubusercontent.com/51533330/130655275-a695a506-0333-4be3-af18-e9d9aeef85ae.jpg)
![20160712110935064](https://user-images.githubusercontent.com/51533330/130655279-5adf9757-6fa0-4559-9dbc-d51ce74ae042.png)
![vim_cheat_sheet_for_programmers_screen](https://user-images.githubusercontent.com/51533330/130655282-57b3d580-3cce-4963-8e43-def21e02232f.png)

## Vim更新
    $git clone https://github.com/vim/vim.git
    $cd vim && ./configure --prefix=$HOME/.local --enable-python3interp=yes && make && sudo make install
    $echo "alias vim='~/.local/bin/vim'" >> ~/.bashrc
    $source ~/.bashrc
### no terminal library found错误
    Ubuntu：
    $sudo apt install libncurses5-dev
    CentOS：
    $sudo yum install ncurses-devel.x86_64

## VSCode Vim 
    gd               = 跳转到单词首次出现行
    gh               = 查看光标所在处错误信息
    gb               = 找出与光标下相同的下一个单词, 并添加一个光标 ，接下来就可以同时修改
