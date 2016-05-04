#!/bin/bash
if [ `ps -e | grep -c spotify.sh` -gt 2 ]; then echo "Already running, i'm killing old process, please run it again!"; killall -9 Xvfb; killall -9 chrome; killall -9 chromium-browser; killall -9 chromium; killall -9 sleep; killall -9 spotify.sh && exit 1; fi
usage() { echo -e "Usage: $0 [-t <Timer to restart chrome (seconds)>] -s \"account,password\" [-l <Separate traffic exchange links with space delimiter(in quote)>]\nExample: $0 -t 3600 -l http://22hit...\nExample: $0 -t 3600 -l \"http://22hit... http://247webhit... http://...\"\nExample: $0 -t 3600 -o \"otohit_account,otohits_password\" -l \"http://22hit...\"\nExample: $0 -t 3600 -o \"otohit_account,otohits_password\"" 1>&2; exit 1; }
[ $# -eq 0 ] && usage
while getopts ":ht:l:s:" arg; do
    case $arg in
        t)
            timer=${OPTARG}
            ;;
        l)
            links=${OPTARG}
            ;;
        s)
            IFS=', ' read -r -a spotify <<< ${OPTARG}
            ;;
        h | *)
            usage
            exit 1
            ;;
    esac
done
if [ -z "${timer}" ]; then
    usage
fi
echo "Checking update Chrome and related package..."
wget --no-check-certificate -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get clean
apt-get autoclean
apt-get autoremove -y
apt-get install -y psmisc
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
echo "Killing old chrome and virtual X display..."
pkill -9 -o chrome
killall -9 chrome
killall -9 Xvfb
killall -9 sleep
while :
do
    echo "Downloading chrome user data dir profile..."
    wget --no-check-certificate http://duclvz.github.io/chromeBotSpotify.tar.gz -O /root/chromeBotSpotify.tar.gz
    echo "Recreating/extracting chrome user data dir..."
    rm -fr /root/chromeBotSpotify/
    tar -xzf /root/chromeBotSpotify.tar.gz -C /root/
    echo "Starting virtual X display..."
    Xvfb :2 -screen 1 1024x768x16 -nolisten tcp & disown
    echo "Starting chrome TE viewer..."
    echo "Open link $links"
    if [ -z "${spotify}" ]
    then
        DISPLAY=:2.1 google-chrome --no-sandbox --user-data-dir="/root/chromeBotSpotify" --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36" --disable-popup-blocking --incognito ${links} & disown
        chromePID=$!
    else
        sed -i "s/spotacc/${spotify[0]}/g" ./chromeBotSpotify/Default/Extensions/ogmejhmjikaeegmhmdpihchmcmppmbof/1.0_0/account.json
        sed -i "s/spotpass/${spotify[1]}/g" ./chromeBotSpotify/Default/Extensions/ogmejhmjikaeegmhmdpihchmcmppmbof/1.0_0/account.json
        DISPLAY=:2.1 google-chrome --no-sandbox --user-data-dir="/root/chromeBotSpotify" --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36" --disable-popup-blocking --incognito ${links} & disown
        chromePID=$!
    fi
    sleep ${timer}
    timeplus=$(shuf -i 10-100 -n 1)
    sleep ${timeplus}
    echo "Kill chrome PID $chromePID"
    kill $chromePID
    echo "Killing virtual X display..."
    killall -9 Xvfb
    echo "Restart TE bots after $((${timer}+${timeplus})) seconds."
done