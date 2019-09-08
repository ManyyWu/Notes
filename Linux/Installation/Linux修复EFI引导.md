# 修复Linux EFI引导
安装盘引导进入tty2
sudo su
mount /dev/sda5 /mnt
mkdir -p /mnt/boot/efi && mount /dev/sda1 /mnt/boot/efi
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev/ /mnt/dev
mount -t devpts pts /mnt/dev/pts/
chroot /mnt
grub-install /dev/sda1
update-grub2
exit
reboot