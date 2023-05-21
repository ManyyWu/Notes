# Git

## Github代理
  ```
  # /etc/hosts
  mirror.ghproxy.com github.com
  mirror.ghproxy.com raw.githubusercontent.com
  ```

## 文档
  * [文档](https://git-scm.com/book/zh/v2)
  * [图解](https://marklodato.github.io/visual-git-guide/index-zh-cn.html)
    
## 提交流程
![image](https://user-images.githubusercontent.com/51533330/132275569-5bf43f4f-271d-4176-b8cc-25cf90978108.png)

# 基础知识
    HEAD为指向当前所在的本地分支的指针

# 命令
## 配置
### 配置重复时删除配置
    $git config --global --unset-all xxx
### 设置用户名和邮箱
    $git config --global user.name "名字"
    $git config --global user.email "邮箱"
### 设置编辑器
    $git config --global core.editor vim
### 查看配置
    $git config --list --local    # 查看本地配置
    $git config --list --global   # 查看全局配置
### 别名
    $git config --global alias.diffvim '!git diff | vim -R -' # 使用vim查看，支持gbk
    $git config --global alias.logtree '!git log --oneline --graph --decorate --all'  # 查看树形图

## 远程仓库
### 查看已配置的远程仓库
    $git remote -v
### 添加和删除远程仓库
    $git remote add repo URL
    $git remote remove repo
### 查看远程分支
    $git remote show repo
### 创建新仓库
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
### 拉取但不合并
    $git fetch origin               # 拉取所有分支
    $git fetch origin b             # 拉取分支b
### 拉取并合并
    $git pull origin                # 拉取并合并所有分支
    $git pull origin b              # 拉取并合并分支b
    $git pull --rebase origin b     # 相当于git feth + git rebase
### 拉取时使用--rebase
    $git stash                      # 有修改未提交时储藏起来
    $git pull --rebase origin b
    $git stash pop                  # 还原
### git push -u
    $git push -u origin master    # -u参数使本地分支与远程的分支建立联系，下次git push/pull使用默认联系
### 拉取远程分支
    $git clone -b b url.git
    或
    $git checkout -b b origin/b

## 提交记录
### 查看详细提交记录
    $git log --pretty=format:"%h %cn %cd %s" --graph -p -3         # 显示差异
    $git log --pretty=format:"%h %cn %cd %s" --graph --name-status # 只显示差异文件名
### 查看已追踪的文件与HEAD的差异
    $git diff --staged file
    或
    $git diff --cached file
### 查看未push的提交
    $git log master ^origin/master
### 查看未push的修改
    $git diff master ^origin/master
### 查看差懂吗
    $git show HASH
### git log过滤参数
  * 按数量: `-3`
  * 按日期: `--after="2014-7-1" --before="2014-7-4"`或`--since="2014-7-1" --until="2014-7-4"`，还支持`1 week ago` `yesterday` `1 hourago` `1 day ago`等
  * 按作者: `git log --author="John\|Mary"`
  * 按备注: `git log --grep="xxxx"`
  * 按文件: `git log -- 1.c 1.h`
  * 按内容增删: `git log -S "Hello World!"`，-G可使用正则表达式
  * 按HASH: `git log HEAD~3 HEAD`

## 分支
### 查看分支
    $git branch           # 查看本地分支
    $git branch -r        # 查看远程分支
    $git branch -a        # 查看本地分支和远程分支
### 创建分支
    $git branch b         # 新建分支
    $git push -u origin b # push
### 合并分支
    $git checkout b       # 切换到分支b
    $git merge master     # 合并b到master
### 变基
    $git checkout b       # 切换到分支b
    $git rebase master    # 将分支b变基到master，此时b领先于master
### 替换分支
    $git checkout old            # 切换到旧分支
    $git reset --hard new        # 将本地的旧分支重置成新分支
    $git push origin new --force # 推送到远程仓库
### 克隆分支
    $git clone -b b url directory
### 删除分支
    $git branch -d b               # 删除本地分支b
    $git push origin --delete b    # 删除远程分支
    或
    $git branch -d -r b            # 删除远程分支b
### 合并仓库
    将b远程仓库合并到本地仓库a
    $git clone https://github.com/xxxx/a.git
    $git remote add b https://github.com/xxxxx/b.git
    $git fetch b
    $git merge b/master
    或
    $git pull https://github.com/xxxxx/b.git master

## 撤销更改
### 修改最近的提交内容和注解
    $git commit --amend
### 回退暂存区中的新文件到工作区(staged -> untracked)，
    $git rm --cached filename
    或
    $git reset HEAD filename
    或
    $git restore --staged filename # (version >= 2.23)
### 删除暂存区中的新文件，直接删除(staged -> deleted)
    $git rm --force filename
### 回退暂存区中的文件到工作区(staged -> changes not staged)
    $git reset HEAD filename
    或
    $git restore --staged filename # (version >= 2.23)
### 取某个版本的文件覆盖暂存区(暂存区的文件会取消暂存，回到工作区)
    $git reset HEAD filename
### 取某个版本的文件覆盖工作区(暂存区和工作区会同时改变)
    $git checkout HEAD filename
### 用远程分支覆盖当前分支(注意不要切错分支)
    $git reset --hard origin/master
    $git push -f
### 撤销工作区中的修改(工作区回到暂存区中的版本)
    $git checkout -- filename # 先从缓存区中拉取版本还原，如果缓存区中没有对应的文件则版本库中拉取还原
    或
    $git restore filename # (version >= 2.23)
### 添加、删除、移动文件
    $git add filename
    $git rm filename
    $git mv filename
    $git commit -m "msg"
    $git push -u origin master
### 丢弃未跟踪的新增的文件或目录
    $git clean -df -n filename # 不实际删除，展示将要进行的操作
    $git clean -df filename    # 删除文件或目录
### 删除提交记录
    $git reset --soft HEAD~1    # 删除git log显示的第一条提交记录，不回退代码
    $git reset --hard HEAD~1    # 删除git log显示的第一条提交记录并且回退代码
### 删除远程仓库
    $git remote rm origin
### 回滚
    $git revert hash-id
### 压缩提交
    $git reabse -i HEAD~N           # 从HEAD~(N-1)开始合并，区间(HEAD~(N-1), HEAD)。举例：`git rebase -i HEAD~2`即合并最近两个提交
    $git rebase --interactive HASH  # 从HASH的下一个开始合并，区间(HASH, HEAD]
    进入交互界面后从第二个提交开始把pick改为s，然后保存退出
    
## Tag
    $git tag        # 查看tag
    $git tag newtag # 新建tag
    $git push --tag newtag # 提交到tag

## 保存密码
    $git config --global credential.helper store

## github免密
    $ssh-keygen -t rsa -C "email"
    $cat ~/.ssh/id_rsa.pub
    复制到Github-SSH keys
    $eval "$(ssh-agent -s)"
    $ssh-add ~/.ssh/id_rsa
    $ssh -T git@github.com # 测试是否生效
    $git remote set-url origin git@github.com:<Username>/<Project>.git # 必须设置才能免密

## 跨平台时换行符问题
### 配置
  * git config credential.helper store # 保存账号密码
  * git config gui.encoding utf-8      # 避免git gui乱码
  * git config core.quotepath off      # 避免git status乱码
  * git config core.safecrlf true      # 禁止提交混合换行符
  * git config core.autocrlf input     # 提交时CRLF转换为LF，检出时不转换
### 更新当前分支所有文件以反映新配置：
  1. 先备份未提交的修改
  2. git rm -rf --cached .
  3. git reset --hard HEAD
### 注意：
  Git自动确定存储库中的文件是文本文件还是二进制文件，为避免二进制文件损坏，可以.gitattrbutes中显式标记[参考](https://docs.github.com/zh/get-started/getting-started-with-git/configuring-git-to-handle-line-endings?platform=linux)
    
## 代理
### 只对github.com
    git config --global http.https://github.com.proxy socks5://127.0.0.1:1080
### 全局
    $git config --global http.proxy 'socks5://127.0.0.1:1080'
    $git config --global https.proxy 'socks5://127.0.0.1:1080'
    或
    $git config --global http.proxy 'http://127.0.0.1:1080'
    $git config --global https.proxy 'https://127.0.0.1:1080'
### 取消全局代理
    $git config --global unset http.proxy
    $git config --global unset https.proxy

## 子模块
### 克隆含子模块的仓库
    $git clone --recursive https://github.com/imtianx/MainProject.git
    或
    $git clone  https://github.com/imtianx/MainProject.git
    $git submodule init
    $git submodule update
### 添加子模块
    $git submodule add https://github.com/manyywu/test.git test
    $git commit
### 删除子模块
    $rm -rf 子模块目录 删除子模块目录及源码
    $vi .gitmodules 删除项目目录下.gitmodules文件中子模块相关条目
    $vi .git/config 删除配置项中子模块相关条目
    $rm .git/module/* 删除模块下的子模块目录，每个子模块对应一个目录，注意只删除对应的子模块目录即可
    执行完成后，再执行添加子模块命令即可，如果仍然报错，执行如下
    $git rm --cached 子模块名称
### 使用子模块
    $git submodule init
    $git submodule update
    或
    $git submodule update --init --recursive
    
## 头指针分离解决办法
    $git branch -f master HEAD  # 强制将 master 分支指向当前头指针的位置
    $git checkout master        # 检出 master 分支

## LFS
### 忽略git-lfs文件
    $git config --global filter.lfs.smudge "git-lfs smudge --skip -- %f"
    $git config --global filter.lfs.process "git-lfs filter-process --skip"
    $git xxx
    $git lfs xxx
### 还原
    $git config --global filter.lfs.smudge "git-lfs smudge -- %f"
    $git config --global filter.lfs.process "git-lfs filter-process"
### 临时忽略git-lfs文件
    $GIT_LFS_SKIP_SMUDGE=1 git xxx
### 清除lfs历史
    $git lfs prune
    
## 冲突
    \<\<\<\<\<\<\< Updated upstream\n[\W\w]*?=======\n([\W\w]*?)>>>>>>> Stashed changes\n
    
## git-windows
### [安装pacman](https://blog.zeromake.com/pages/windows-terminal-configuration/)
 
## 显示分支图
    $git log --graph decorate --oneline --simplify-by-decoration --all
    $git log --graph --oneline --all
## [icdiff](https://github.com/jeffkaufman/icdiff)

##常见问题：
  * SSL: no alternative certificate subject name matches target host name  
    $git config --global http.sslVerify false

# 图示
[图示](https://zhuanlan.zhihu.com/p/132573100)
