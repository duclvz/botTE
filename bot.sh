#!/bin/bash
if [ `ps -e | grep -c bot.sh` -gt 2 ]; then echo "Already running, i'm killing old process, please run it again!"; killall -9 bot.sh; killall -9 Xvfb; killall -9 chrome; killall -9 chromium-browser; killall -9 chromium; killall -9 sleep && exit 1; fi
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
echo "Checking update Chromium and related package..."
apt-get update
apt-get clean
apt-get autoclean
apt-get autoremove -y
apt-get install -y psmisc
apt-get install -y xvfb x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xfonts-cyrillic x11-apps
apt-get install -y gtk2-engines-pixbuf libexif12 libxpm4 libxrender1 libgtk2.0-0
apt-get install -y libnss3 libgconf-2-4
apt-get install -y chromium-browser
dpkg --configure -a
apt-get install -f -y
if [[ `lsb_release -rs` == "12.04" ]]
then
    apt-get install -y defoma x-ttcidfont-conf
    (cd /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType && mkfontdir > fonts.dir)
fi
echo "Downloading chromium user data dir profile..."
wget --no-check-certificate https://raw.githubusercontent.com/duclvz/botTE/master/chromiumBotTE.tar.gz -O /root/chromiumBotTE.tar.gz
echo "Killing old chromium and virtual X display..."
pkill -9 -o chrome
pkill -9 -o chromium-browser
pkill -9 -o chromium
killall -9 chrome
killall -9 chromium-browser
killall -9 chromium
killall -9 Xvfb
killall -9 sleep
while :
do
    echo "Recreating/extracting chromium user data dir..."
    rm -fr /root/chromeBotTE/
    tar -xf /root/chromiumBotTE.tar.gz -C /root/
    echo "Starting virtual X display..."
    Xvfb :1 -screen 1 1024x768x16 -nolisten tcp & disown
    echo "Starting chromium TE viewer..."
    declare -a chromePIDs
    for i in ${!links[@]}
    do
        echo "Open link ${links[$i]}"
        DISPLAY=:1.1 chromium-browser --no-sandbox --new-window --user-data-dir="/root/chromeBotTE" --disable-popup-blocking --incognito ${links[$i]} & disown
        chromePIDs[$i]=$!
    done
    sleep ${timer}
    for element in ${chromePIDs[@]}
    do
        echo "Kill chromium PID $element"
        kill $element
    done
    echo "Killing virtual X display..."
    killall -9 Xvfb
    echo "Restart TE bots after ${timer} seconds!!"
done