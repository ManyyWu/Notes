## 1. 教程
* [未知来源](https://www.jianshu.com/p/ec2572e3143d)

## 2. 软件
* [终端系统状态查看](https://github.com/nicolargo/glances)
* [Install homebrew](https://zhuanlan.zhihu.com/p/90508170)
* Hex_Fiend_2.8二进制编辑.dmg
* 尘归尘
* 拉力赛艺术 (art of rally)
* 软件大全.txt
* 荧火虫vpn.dmg
* 原码.txt
* Bartender状态栏增强工具
* BMXCloud.MacNet.Latest.dmg
* CLion-2020.2.4.dmg
* Command_Line_Tools_for_Xcode_12.dmg
* DiffMerge.4.2.1.1013.intel.stable文件比较.dmg
* Dynamic Wallpaper
* EFI-only_v3.7.zip
* Geekbench 5.app
* Go2Shell-finder打开终端.dmg
* Go2Shell.txt
* googlechrome.dmg
* Hackintool.zip
* ieaseMusic-1.3.4-mac.dmg
* IORegistryExplorer-2.1.dmg
* iStat Menus
* jetbrains-agent-latest.zip
* Keka
* Magnet 2.4.9窗口管理.dmg
* Mos.Versions.3.1.0平滑滚动.dmg
* MY_EFI_BAK.zip
* OCC.zip
* office 2019
* Parallels Desktop Business Edition v16.0.1-48919 Crked - Digit77.com - 关闭网络安装，关闭自动更新.dmg
* Sensei_1.2.4垃圾清理.dmg
* Tuxera_NTFS_2019.dmg
* tuxerantfs_2019_wm.dmg
* VideoProc_3.9..dmg
* VirtualBox-6.1.16-140961-OSX.dmg
* VSCode-darwin-stable.zip
* Wireshark 3.4.0 Intel 64.dmg

## 3. 关闭自动更新
```
$sudo softwareupdate --ignore "macOS Catalina"
$defaults write com.apple.systempreferences AttentionPrefBundleIDs 0
$killall Dock
```

## 4. dislocker
$brew install dislocker
```
#!/bin/bash

sudo dislocker -v -V /dev/disk2s1  -u -- /Volumes/MyDocuments
sudo hdiutil attach -imagekey diskimage-class=CRawDiskImage /Volumes/MyDocuments/dislocker-file
```
