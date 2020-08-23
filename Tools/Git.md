# 图形化软件软件
## MacOS
* tortoiseGit
* Sourcetree
## Windows
* Sourcetree
# 命令行
## 设置账号和邮箱
    $git config --global user.name "名字"
    $git config --global user.email "邮箱"
## 创建新仓库:
    首先在github创建仓库repo
    $mkdir repo                   # 新建文件夹
    $git init                     # 初始化git
    $touch README.md              # 新建README.md
    $git add *                    # 添加文件
    $git commit -m "first commit" # 提交
    $git remote add origin https://github.com/username/repo.git # 添加远程仓库
    或
    $git config remote.origin.url=https://github.com/username/repo.git #修改远程仓库
    $git push -u origin master -f # push
## 更新代码：
    $git pull <url> <branch>
## 查看分支：
    $git fetch            # 同步分区
    $git branch           # 查看本地分支
    $git branch -r        # 查看远程分支
    $git branch -a        # 查看本地分支和远程分支
## 创建分支:
    $git branch b         # 新建分支
    $git push -u origin b # push
## 合并分支:
    $git checkout b       # 切换到分支b
    $git merge master     # 合并b到master
    $git push -u origin b # push
## 替换分支
    $git checkout old            # 切换到旧分支
    $git reset --hard new        # 将本地的旧分支重置成新分支
    $git push origin new --force # 推送到远程仓库
## 克隆分支:
    $git clone -b b url directory
## 删除分支:
    $git brance -d b               # 删除本地分支b
    $git branch -d -r b            # 删除远程分支b
## 添加、删除、移动文件:
    $git add filename
    $git rm filename
    $git mv filename
    $git commit -m "msg"
    $git push -u origin master
## 丢弃工作区的修改
    $git checkout --filename
## 删除已提交记录:
    $git log                 # 查询提交记录
    $git reset --soft HEAD~1 # 删除git log显示的第一条提交记录，不删除修改记录
    $git reset --hard HEAD~1 # 删除git log显示的第一条提交记录和修改记录(撤销上一次的更改)
    $git push origin master -f # 强制提交
## 删除远程仓库：
    $git remote rm origin
## 撤销(未push)：
    $git checkout filename   # 撤销指定文件
    $git checkout .          # 撤销所有文件
    $git reset HEAD filename # git add后撤销指定文件
    $git reset HEAD .        # git add后撤销所有文件
    $git reset HEAD filename && git checkout HEAD filename # 修改、删除文件后找回指定文件
    $git reset HEAD . && git checkout HEAD .     # 修改、删除文件后找回所有
    $git reset HEAD~1 filename && git checkout HEAD~1 filename # 修改、删除且commit后找回指定文件
    $git reset HEAD~1 . && git checkout HEAD~1 . # 修改、删除且commit后找回所有文件
## 回滚(已push)：
    $git checkout 
## Tag
    $git tag        # 查看tag
    $git tag newtag # 新建tag
    $git push --tag newtag # 提交到tag
## 删除远程仓库
    $git push -d origin b # 删除远程分支b
## Git设置全局代理
    ssr设置好socks5代理端口
    $git config --global http.proxy 'socks5://127.0.0.1:1080'
    $git config --global https.proxy 'socks5://127.0.0.1:1080'
## 取消全局代理
    $git config --global unset http.proxy
    $git config --global unset https.proxy
## 免密
    $ssh-keygen -t rsa -C "email"
    $cat ~/.ssh/id_rsa.pub
    复制到Github-SSH keys
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    ssh -T git@github.com # 测试是否生效
    git config --global url=git@github.com:username/repo.git
## proxy
### 只对github.com
    git config --global http.https://github.com.proxy socks5://127.0.0.1:1080
### 全局
    git config --global http.proxy 'socks5://127.0.0.1:1080'
    git config --global https.proxy 'socks5://127.0.0.1:1080'
## 克隆含子模块的仓库
    git clone --recursive https://github.com/imtianx/MainProject.git
    or
    git clone  https://github.com/imtianx/MainProject.git
    git submodule init
    git submodule update
## 添加子模块
    git submodule add https://github.com/manyywu/test.git test
    git commit
## 删除子模块
    rm -rf 子模块目录 删除子模块目录及源码
    vi .gitmodules 删除项目目录下.gitmodules文件中子模块相关条目
    vi .git/config 删除配置项中子模块相关条目
    rm .git/module/* 删除模块下的子模块目录，每个子模块对应一个目录，注意只删除对应的子模块目录即可
    执行完成后，再执行添加子模块命令即可，如果仍然报错，执行如下：
    git rm --cached 子模块名称
## 使用子模块
    git submodule init
    git submodule update
    或
    git submodule update --init --recursive
