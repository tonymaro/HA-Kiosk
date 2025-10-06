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
CHECKFILE="$HOME/scripts/lasttouch.txt"
CHECKNIGHT="$HOME/scripts/nightlight.txt"

export DISPLAY=:0
ROKU_ON=TRUE

# If we are in Roku TV mode, don't do anything
CURLOUT=$(curl -s "$ROKU_IP:8060/query/device-info" 2>/dev/null)
if echo "$CURLOUT" | grep -1 "power-mode>PowerOn"; then
	# The TV is powered on
	echo "TV on"
	CURLOUT=$(curl -s "$ROKU_IP:8060/query/active-app" 2>/dev/null)
	ROKU_ON=TRUE

	if ! echo "$CURLOUT" | grep -1 "tvinput.hdmi1"; then
		# the TV is NOT on HDMI1 input, must be watching a movie
	        exit;
	fi
else
	ROKU_ON=FALSE
fi

if [ -f "$CHECKNIGHT" ]; then
	echo "*** NIGHTLIGHT file exists at $CHECKFILE ***"
	# In nightlight mode, make sure it's on and the slideshow is running
	# see if mpv is running, if not restart it
	# If Roku is off, turn it on
	if [ "$ROKU_ON" = "FALSE" ]; then
		# Turn on the Roku
	        POWER_ON_URL="http://$ROKU_IP:8060/keypress/PowerOn"
	        curl -X POST "$POWER_ON_URL"
	        echo "Powered on"
	        sleep 3
	fi

	if ! pgrep -x "mpv" > /dev/null; then
		echo "Restarting mpv"
		SLIDESHOW="$HOME/Slideshow/nightlight/"
		/usr/bin/mpv -fs --shuffle --image-display-duration=240 --loop-playlist $SLIDESHOW &
		exit
	fi
	# MPV is already running
	exit
fi


CURRENT_TIME=$(date +%s)
LAST_MODIFIED_TIME=$(stat -c %Y "$CHECKFILE")

DIFF_TIME=$((CURRENT_TIME - LAST_MODIFIED_TIME))

# 1800 = half hour
# 900 = 15 minutes
if [ "$DIFF_TIME" -lt 900 ]; then
        # Do nothing, have recently taken action so leave it on for now
	# this ensures dashboard shows a bit after some event
         exit
fi

# if we aren't playing an announcement video, go ahead and turn off the screen
if ! pgrep -x "ffplay" > /dev/null; then
	killall mpv

	POWER_OFF_URL="http://$ROKU_IP:8060/keypress/poweroff"
	curl -X POST "$POWER_OFF_URL"
	echo "Powered off"
fi
