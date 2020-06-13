# GDB
## 调试子进程
### set detach-on-fork off/on
* off: 这两个过程都将在GDB的控制下进行。follow-fork-mode像往常一样调试一个进程（子进程或父进程，取决于的值），而另一个进程 保持挂起状态。
* on: 子进程（或父进程，取决于的值 follow-fork-mode）将被分离并允许独立运行。这是默认值。
    
### set follow-fork-mode child/parent
* child: 新进程在派生后进行调试。父进程不受阻碍地运行。
* parent: 原始过程在派生后进行调试。子进程不受阻碍地运行。这是默认值。
### show detach-on-fork
### show follow-fork-mode
