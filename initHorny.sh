#!/bin/bash
echo "Checking update Chrome and related package..."
killall apt-get
killall dpkg
apt-get update
apt-get clean
apt-get autoclean
apt-get autoremove -y
apt-get install -y psmisc lsb-release
sync && sysctl -w vm.drop_caches=3
apt-get install -y x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xfonts-cyrillic x11-apps
apt-get install -y gtk2-engines-pixbuf libexif12 libxpm4 libxrender1 libgtk2.0-0
apt-get install -y libnss3 libgconf-2-4
apt-get install -y libxss1 libappindicator1 libindicator7
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
wget http://duclvz.github.io/google-chrome-$ARCH.deb -O google-chrome-$ARCH.deb
dpkg -i google-chrome-*.deb
dpkg --configure -a
apt-get install -f -y
if [[ `lsb_release -rs` == "12.04" ]]
then
    apt-get install -y defoma x-ttcidfont-conf
    (cd /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType && mkfontdir > fonts.dir)
fi
echo "Downloading chrome user data dir profile..."
wget --no-check-certificate http://duclvz.github.io/chromeHorny.tar.gz -O /root/chromeHorny.tar.gz
echo "Recreating/extracting chrome user data dir..."
rm -fr /root/chromeHorny/
tar -xzf /root/chromeHorny.tar.gz -C /root/