#!/bin/bash
#
# stop everything, turn off the TV
# THIS SCRIPT IS FOR LOCAL EXECUTION, NOT REST API!
#
# This gets called from a crontab event
#
# Written by Anthony Maro   September 29th, 2025
#
# This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
#
# You are free to:
# - Share — copy and redistribute the material in any medium or format
# - Adapt — remix, transform, and build upon the material
#
# Under the following terms:
# - Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
# - NonCommercial — You may not use the material for commercial purposes.
#
# To view a copy of this license, visit:
#   https://creativecommons.org/licenses/by-nc/4.0/
#
##########################################


# ip of your Roku TV:
ROKU_IP="192.168.5.186"

export DISPLAY=:0

# If we are in Roku TV mode, don't do this
CURLOUT=$(curl -s "$ROKU_IP:8060/query/active-app" 2>/dev/null)

if ! echo "$CURLOUT" | grep -1 "tvinput.hdmi1"; then
        echo "Roku is ative"
        exit;
fi



# If we are in nightlight mode don't do this
if [ -f ~/scripts/nightlight.txt ]; then
	# see if mpv is running, if not restart it
	if ! pgrep -x "mpv" > /dev/null; then
		echo "Restarting mpv"
		SLIDESHOW="$HOME/Slideshow/nightlight/"
		/usr/bin/mpv -fs --shuffle --image-display-duration=240 --loop-playlist $SLIDESHOW &
		exit;
	fi
fi


CHECKFILE="$HOME/scripts/lasttouch.txt"

CURRENT_TIME=$(date +%s)
LAST_MODIFIED_TIME=$(stat -c %Y "$CHECKFILE")

DIFF_TIME=$((CURRENT_TIME - LAST_MODIFIED_TIME))

# 1800 = half hour
# 900 = 15 minutes
if [ "$DIFF_TIME" -lt 900 ]; then
        # Do nothing, have recently taken action so leave it on for now
         exit
fi

# if we aren't playing an announcement video, go ahead and turn off the screen
if ! pgrep -x "ffplay" > /dev/null; then
	killall mpv

	POWER_OFF_URL="http://$ROKU_IP:8060/keypress/poweroff"
	curl -X POST "$POWER_OFF_URL"
	echo "Powered off"
fi
