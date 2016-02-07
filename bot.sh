#!/bin/bash
if [ `ps -e | grep -c botTE.sh` -gt 2 ]; then echo "Already running, i'm killing old process, please run it again!"; killall -9 botTE.sh && exit 1; fi
usage() { echo -e "Usage: $0 [-t <Timer to restart chrome (seconds)>] [-l <Separate traffic exchange links with space delimiter(in quote)>]\nExample: $0 -t 3600 -l http://22hit...\nExample: $0 -t 3600 -l \"http://22hit... http://247webhit... http://...\"" 1>&2; exit 1; }
[ $# -eq 0 ] && usage
while getopts ":ht:l:" arg; do
    case $arg in
        t)
            timer=${OPTARG}
            ;;
        l)
            IFS=' ' read -r -a links <<< ${OPTARG}
            ;;
        h | *)
            usage
            exit 1
            ;;
    esac
done
if [ -z "${timer}" ] || [ -z "${links}" ]; then
    usage
fi
echo "Checking update Chrome and related package..."
wget --no-check-certificate -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get clean
apt-get autoclean
apt-get autoremove
apt-get install -y xvfb gtk2-engines-pixbuf libexif12 libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xfonts-cyrillic x11-apps google-chrome-stable
dpkg --configure -a
apt-get install -f -y
if [[ `lsb_release -rs` == "12.04" ]]
then
    apt-get install -y defoma x-ttcidfont-conf
    (cd /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType && mkfontdir > fonts.dir)
fi
echo "Downloading chrome user data dir profile..."
wget --no-check-certificate https://raw.githubusercontent.com/duclvz/botTE/master/chromeBotTE.tar.gz -O /root/chromeBotTE.tar.gz
while :
do
    echo "Killing chrome and virtual X display..."
    for element in ${links[@]}
    do
        pkill -9 -o chrome
    done
    killall -9 chrome
    killall -9 Xvfb
    echo "Recreating/extracting chrome user data dir..."
    rm -fr /root/chromeBotTE/
    tar -xf /root/chromeBotTE.tar.gz -C /root/
    echo "Starting virtual X display..."
    Xvfb :1 -screen 1 1024x768x16 -nolisten tcp & disown
    echo "Starting chrome TE viewer..."
    for element in ${links[@]}
    do
        echo "Open link $element"
        DISPLAY=:1.1 google-chrome --no-sandbox --disable-gpu --new-window --user-data-dir="/root/chromeBotTE" --disable-popup-blocking --incognito $element & disown
    done
    sleep ${timer}
    echo "TELog: Restart TE bots"
done