# GDB
### ~/.gdbinit
  [STL]([STL GDB evaluator](https://gist.github.com/chaozh/9252fc01b3723f795589)s)

### 开始:
    start                                          开始
    run [<args>]                                   (r)运行
    kill                                           (k)停止
    attach <pid>                                   (at)附加进程
    detach <[pid]>                                 (det)释放进程
    contine <[count]>                              (c)继续执行直到下一个断点，count为跳过的断点数
    next                                           (n)
    step                                           (s)
    finish                                         (fin)
    until <[line]>                                 (un)
          <[file]:[line]>
          <[file]:[function]>
          <[address]>
    jump <[line]>                                  (j)跳转到指定位置，直接跨函数会导致栈错误
         <[file]:[line]>
         <[file]:[function]>
         <[address]>
    call <expr>                                    强制执行函数
    return <expr>                                  (ret)退出当前函数

### 显示代码:
    $gdb <file> -tui
    list <[start>],[end]>                          (l)显示附近代码
         <[function]>
         <[file:line]>
         <[file:function]>
    set listsize <num>                             设置list行数
    show listsize                                  显示list行数

### 断点:
    info break                                     (i b)显示断点或watch，断点序号num
    break <[line]> [if <cond>] [thread <num>]      (b)断点，默认下一行
          <[file]:[line]>
          <[file]:[function]>
          <[address]>
    tbreak                                         (tb)临时断点
    disable <[num]>                                (dis)禁用断点，无参默认当前行
    enable <[num]>                                 (en)启用断点，无参默认当前行
    delete <[num]>                                 (de)删除断点，无参默认删除所有
    clear <[line]>                                 (cl)删除断点或watch(watch是特殊的断点)
    condition <num> <[expr]>                       (cond)不指定expr则清除条件
    ignore <num> <count>                           (ig)忽略count次断点

### 断点命令:
    commands [num]                                 断点时批量执行命令
    ... command-list ...
    end

### 变量和表达式:
    print <[/fmt]> <expr>                          (p)打印变量或表达式
          <file:var>
          <function:var>
    print <arr>                                    打印数组内容
    print <*ptr[@num]>                             数组形式打印指针内容
          /x 按十六进制格式显示变量
          /d 按十进制格式显示变量
          /u 按十六进制格式显示无符号整型
          /o 按八进制格式显示变量
          /t 按二进制格式显示变量
          /a 按十六进制格式显示变量
          /c 按字符格式显示变量
          /f 按浮点数格式显示变量
    info watch                                     (i wat)查看watch
    watch <expr>                                   (wat)变量或表达式发生改变时暂停
    rwatch <expr>                                  (rw)读变量时暂停
    awatch <expr>                                  (aw)写变量时暂停
    display <expr>                                 (disp)每次暂停时打印变量或表达式
    info display                                   (i di)查看display
    undisplay <num>                                (und)删除display，无参默认删除所有
    x <[/fmt]> <address>                           查看内存值
    print <var = new_val>                          修改变量值
    set print pretty on                            打印结构体时每个成员都换行

### 堆栈:
    where                                          (wh)
    backtrace                                      (bt)
    info args                                      (i ar)打印当前帧参数
    info locals                                    (i lo)打印当前帧所有局部变量
    info catch                                     (i ca)打印当前帧异常信息
    backtrace full                                 (b fu)打印当前帧和局部变量

### 寄存器:
    info register <[name]>                         (i reg)查看寄存器
    info all-register                              (i all)查看所有器

### TUI:
    PgUp|PgDn|Up|Down|Left|Right                   翻页
    c-l                                            刷新界面
    layout src|asm|reg|split                       (lay)打开窗口
    focus src|asm|reg|split                        (fs)激活窗口
    winheight src +5|-5                            调整窗口大小

### 组合键:
    c-x a                                          开关TUI
    c-x 1                                          分割一个窗口
    c-x 2                                          分割两个窗口
    c-x o                                          切换窗口
    c-x s                                          单键模式

### 单键模式:
    c                                              continue
    f                                              finish
    n                                              next
    s                                              step
    r                                              run
    u                                              up
    v                                              info locals
    w                                              where
    q                                              quit

### 进程:
    info inferiors                                 查看进程状态，进程序号num
    inferior <num>                                 切换进程

### 线程:
    info thread                                    (i th)显示线程，线程序号num
    thread <num>                                   切换线程

### 其他:
    set confirm off                                关闭退出确认
    set paigination off                            打印信息多时不暂停

### 调试子进程/线程
    set detach-on-fork off/on
        off: 这两个过程都将在GDB的控制下进行。follow-fork-mode像往常一样调试一个进程（子进程或父进程，取决于follow-fork-mode的值），而另一个进程 保持挂起状态
        on: 子进程（或父进程，取决于follow-fork-mode的值）将被分离并允许独立运行。这是默认值
        
    set follow-fork-mode child/parent
        child: 新进程在派生后进行调试。父进程不受阻碍地运行
        parent: 原始过程在派生后进行调试。子进程不受阻碍地运行。这是默认值
    show detach-on-fork
    show follow-fork-mode
    set scheduler-locking on/off/step
        on: 表示调试线程执行时，其余线程锁定，阻塞等待
        off: 表示不锁定其他线程
        step: 表示在step（单步）调试时，只有当前线程运行
    show scheduler-locking

## CGDB
### CGDB安装
    $sudo yum install -y ncurses-devel readline-devel automake flex info
    $wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.8.tar.gz && tar zxvf texinfo-6.8.tar.gz && cd texinfo-6.8/ && ./configure --prefix='/usr/local/' && make -j8 && sudo make install
    $git clone -b libvterm https://github.com/cgdb/cgdb.git && cd cgdb && ./autogen.sh && ./configure && make -srj4 && sudo make install
### CGDB命令
    * F5: run
    * F6: continue
    * F7: finish
    * F8: next
    * F10: step
    * ESC: vi模式进入代码窗口
    * C-W: 切换横屏
    * C-l: 清屏
    * i: 进入命令窗口
      * I: 进入TTY模式
      * o: 打开文件
      * s: vi模式进入命令窗口，回车结束
      * space: 断点
      * t: 临时断点
      * -/=: 减小/增大代码窗口
    * 向调试程序发送I/O：gdb可以直接输入，而cgdb只能在终端中启动被调试程序，然后在另一个终端使用CGDB去attach被调试程序
    * C-T: 新窗口中打开tty，目前已删除
### [文档](https://leeyiw.gitbooks.io/cgdb-manual-in-chinese/content/3.1.html)
