#!/bin/bash
usage() { echo -e "Usage: $0 -t <Timer to restart chrome (seconds)>] -l <Separate traffic exchange links with space delimiter(in quote)>\nExample: $0 -t 3600 -l http://22hit...\nExample: $0 -t 3600 -l \"http://22hit... http://247webhit... http://...\"\nExample: $0 -t 3600 -l \"http://22hit...\"" 1>&2; exit 1; }
[ $# -eq 0 ] && usage
hornyPort=""
hornyIP=""
while getopts ":ht:l:p:i:" arg; do
    case $arg in
        t)
            timer=${OPTARG}
            ;;
        l)
            links=${OPTARG}
            ;;
        p)
            hornyPort=${OPTARG}
            ;;
        i)
            hornyIP=${OPTARG}
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

while :
do
    echo "Starting new Horny TE viewer..."
    echo "Open link $links"
    DISPLAY=:${hornyPort} google-chrome --no-sandbox --new-window --user-data-dir="/root/chromeHorny" --user-agent="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36" --disable-popup-blocking --incognito ${links} & disown
    browserPID=$!
    sleep ${timer}
    echo "Kill browser PID $browserPID"
    kill $browserPID
    echo "Restart TE bots after ${timer} seconds."
done