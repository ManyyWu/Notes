# Fodora KDE安装


## 中科大源

```base
sudo dnf config-manager setopt \
  fedora.baseurl='https://mirrors.ustc.edu.cn/fedora/releases/$releasever/Everything/$basearch/os/' \
  fedora.metalink= \
  updates.baseurl='https://mirrors.ustc.edu.cn/fedora/updates/$releasever/Everything/$basearch/' \
  updates.metalink=

sudo dnf --repo=fedora --repo=updates --refresh makecache
sudo dnf update
```


## Fcitx

```bash
sudo dnf install fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-gtk fcitx5-qt
```

设置 - 键盘 - 虚拟键盘 - 选择“Fcitx 5”，解压虎码配置到~/.local/share/fcitx5/，然后重新登录

启动设置：

```bash
fcitx5-configtool
```

关闭自动上屏：

Fcitx配置 - 虎码 - 设置图标 - 取消勾选“自动选择选词”（注意不是：自动选择候选词后提交）

对应配置文件 `.config/fcitx5/table/tiger.conf` 中的 `AutoSelect=False`，修改后使用 `fcitx5 -rd` 重启


## 应用内无法输入中文的问题

ChatGPT: 添加命令行参数 `--ozone-platform=wayland %U`


## 字体

```bash
sudo dnf install -y rsms-inter-fonts google-noto-sans-sc-fonts jetbrains-mono-fonts 
```

设置 - 文本和字体 - 字体 - 把“等宽”修改为“JetBrains Mono”，其他字体设置为"Inter"

Konsole新建配置方案，字体选择“JetBrains Mono”，并取消勾选“用粗体绘制强烈颜色”


## sudo

* 密码宽限时间

  ```bash
  printf 'Defaults:%s timestamp_timeout=30\n' "$(id -un)" | sudo tee /etc/sudoers.d/99-timestamp-timeout >/dev/null
  ```

* 默认编辑器

  ```bash
  sudo EDITOR=/usr/bin/vim visudo
  ```

  添加

  `Defaults editor=/usr/bin/vim`

* 添加路径

  `Defaults secure_path` 后加入 `:/home/manyy/bin`


## Kitty终端

```bash
sudo dnf install kitty
# 主题选择
kitten themes --reload-in=all 'Monokai'
# 字体配置
kitten choose-fonts
```

配置文件：`~/.config/kitty/kitty.conf`

```
# 修改字体大小添加
font_size 10
# 关闭提示声：
enable_audio_bell no
```

> xterm-kitty定义问题，在`.ssh/config`中给Host添加：
> 
> ```
> SetEnv TERM=xterm-256color
> ```


## Toshy

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/RedBearAK/toshy/main/scripts/bootstrap.sh)"
```

快捷键 - Plasma工作空间 - 取消勾选“Meta”的快捷键


## Discover卡死

尝试以命令行打开

```bash
plasma-discover --mode Update
```


## bws.sh

参考 [bws.sh文档](vaultwarden-backup/README.md)