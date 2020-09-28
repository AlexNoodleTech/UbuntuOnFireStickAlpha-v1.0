apt-get update && apt-get upgrade
apt-get install wget tar gzip nano proot -y
wget http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/ubuntu-base-16.04-core-armhf.tar.gz
gzip -d ubuntu-base-16.04-core-armhf.tar.gz
tar -xf ubuntu-base016.04-core-armhf.tar
mkdir -p ubuntu20-binds
bin=start-ubuntu20.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A ubuntu20-binds)" ]; then
    for f in ubuntu20-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b ubuntu20-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

mkdir -p ubuntu20-fs/var/tmp
rm -rf ubuntu20-fs/usr/local/bin/*

wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/.profile -O ubuntu20-fs/root/.profile.1
cat $folder/root/.profile.1 >> $folder/root/.profile && rm -rf $folder/root/.profile.1
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vnc -P ubuntu20-fs/usr/local/bin
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncpasswd -P ubuntu20-fs/usr/local/bin
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncserver-stop -P ubuntu20-fs/usr/local/bin
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncserver-start -P ubuntu20-fs/usr/local/bin

chmod +x ubuntu20-fs/root/.bash_profile
chmod +x ubuntu20-fs/root/.profile
chmod +x ubuntu20-fs/usr/local/bin/vnc
chmod +x ubuntu20-fs/usr/local/bin/vncpasswd
chmod +x ubuntu20-fs/usr/local/bin/vncserver-start
chmod +x ubuntu20-fs/usr/local/bin/vncserver-stop
touch $folder/root/.hushlogin
echo "127.0.0.1 localhost localhost" > $folder/etc/hosts
echo "nameserver 1.1.1.1" > $folder/etc/resolv.conf
chmod +x $folder/etc/resolv.conf
echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
clear
echo "You can now launch Ubuntu with the ./${bin} script form next time"
bash $bin
