#!/bin/bash

echo "Checking update Chrome and related package..."
wget --no-check-certificate -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get clean
apt-get autoclean
apt-get autoremove -y
apt-get install -y psmisc unzip
apt-get install -y libxss1 libappindicator1 libindicator7 python-pip python-dev build-essential
apt-get install -y xvfb x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xfonts-cyrillic x11-apps
apt-get install -y gtk2-engines-pixbuf libexif12 libxpm4 libxrender1 libgtk2.0-0
apt-get install -y libnss3 libgconf-2-4
apt-get install -y google-chrome-stable
dpkg --configure -a
apt-get install -f -y
if [[ `lsb_release -rs` == "12.04" ]]
then
    apt-get install -y defoma x-ttcidfont-conf
    (cd /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType && mkfontdir > fonts.dir)
fi
pip install -U pyvirtualdisplay selenium
LATEST=$(wget --no-check-certificate -q -O - http://chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget --no-check-certificate http://chromedriver.storage.googleapis.com/$LATEST/chromedriver_linux64.zip -O chromedriver_linux64.zip
unzip -u chromedriver_linux64.zip && chmod +x chromedriver
mv -f chromedriver /usr/local/share/chromedriver
ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
ln -s /usr/local/share/chromedriver /usr/bin/chromedriver
wget --no-check-certificate http://duclvz.github.io/chromeTE.tar.gz -O /root/chromeTE.tar.gz
rm -fr /root/chromeTE/
tar -xf /root/chromeTE.tar.gz -C /root/