#!/bin/bash
#
# Start the slideshow app IF conditions are right
#
# THIS SCRIPT GETS CALLED LOCALLY, NOT FROM REST API!
# Called from a crontab event
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


export DISPLAY=:0

# See if slideshow is already running
if ps -ef | grep -v grep | grep mpv; then
	exit 0
fi

CHECKFILE="$HOME/scripts/lasttouch.txt"

CURRENT_TIME=$(date +%s)
LAST_MODIFIED_TIME=$(stat -c %Y "$CHECKFILE")

DIFF_TIME=$((CURRENT_TIME - LAST_MODIFIED_TIME))

# 1800 = half hour
# 900 = 15 minutes
if [ "$DIFF_TIME" -lt 900 ]; then
	# Do nothing, have recently taken action so leave the dashboard up
	# echo "Done action recently"
	exit 0
fi

# We're going to start the slideshow
# Pick the slideshow to run:

SLIDESHOW="$HOME/Slideshow/halloween/"

# Are we in nightlight mode?
if [ -f ~/scripts/nightlight.txt ]; then
	SLIDESHOW="$HOME/Slideshow/nightlight/"
fi

# Just in case it's already running:
killall mpv
sleep 1
nohup /usr/bin/mpv -fs --shuffle --image-display-duration=240 --loop-playlist $SLIDESHOW >/dev/null 2>&1 &
