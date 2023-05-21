# 修复Linux EFI引导
1. 安装盘引导进入tty2
2. sudo su
3. mount /dev/sda5 /mnt
4. mkdir -p /mnt/boot/efi && mount /dev/sda1 /mnt/boot/efi
5. mount -t proc proc /mnt/proc
6. mount -t sysfs sys /mnt/sys
7. mount -o bind /dev/ /mnt/dev
8. mount -t devpts pts /mnt/dev/pts/
9. chroot /mnt
10. grub-install /dev/sda1
11. update-grub2
12. exit
13. reboot