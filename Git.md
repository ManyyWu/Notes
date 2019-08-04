# 设置账号和邮箱
    $git config --global user.name "名字"
    $git config --global user.email "邮箱"
#
# 创建新仓库:
    首先在github创建仓库repo
    $mkdir repo                   # 新建文件夹
    $git init                     # 初始化git
    $touch README.md              # 新建README.md
    $git add *                    # 添加文件
    $git commit -m "first commit" # 提交
    $git remote add origin https://github.com/username/repo.git # 添加远程仓库
    或
    $git config remote.origin.url=https://github.com/username/repo.git #修改远程仓库
    $git push -u origin master    # push
# 更新代码：
    $git pull <url> <branch>
# 查看分支：
    $git branch           # 查看本地分支
    $git branch -r        # 查看远程分支
    $git branch -a        # 查看本地分支和远程分支
# 创建分支:
    $git branch b         # 新建分支
    $git push -u origin b # push
# 合并分支:
    $git checkout b       # 切换到分支b
    $git merge master     # 合并b到master
    $git push -u origin b # push
# 删除分支:
    $git brance -d b               # 删除本地分支b
    $git branch -d -r b            # 删除远程分支b
# 添加、删除、移动文件:
    $git add filename
    $git rm filename
    $git mv filename
    $git commit -m "msg"
    $git push -u origin master
# 丢弃工作区的修改
    $git checkout --filename
# 删除已提交记录:
    $git log                 # 查询提交记录
    $git reset --soft HEAD~1 # 删除git log显示的第一条提交记录，不删除修改记录
    $git reset --hard HEAD~1 # 删除git log显示的第一条提交记录和修改记录(撤销上一次的更改)
    $git push origin master -f # 强制提交
# 删除远程仓库：
    $git remote rm origin
# 撤销(未push)：
    $git checkout filename   # 撤销指定文件
    $git checkout .          # 撤销所有文件
    $git reset HEAD filename # git add后撤销指定文件
    $git reset HEAD .        # git add后撤销所有文件
    $git reset HEAD filename && git checkout HEAD filename # 修改、删除文件后找回指定文件
    $git reset HEAD . && git checkout HEAD .     # 修改、删除文件后找回所有
    $git reset HEAD~1 filename && git checkout HEAD~1 filename # 修改、删除且commit后找回指定文件
    $git reset HEAD~1 . && git checkout HEAD~1 . # 修改、删除且commit后找回所有文件
# 回滚(已push)：
    $git checkout 
# Tag
    $git tag        # 查看tag
    $git tag newtag # 新建tag
    $git push --tag newtag # 提交到tag
# 删除远程仓库
    $git push -d origin b # 删除远程分支b
