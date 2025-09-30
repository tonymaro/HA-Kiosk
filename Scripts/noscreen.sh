#!/bin/bash
#
# Turn off the screen
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

# Stop whatever we are doing
killall ffplay
killall mpv

# Announce we are hibernating based on variables:
if [ "$1" == "announce" ]; then
	if [ "$2" == "goodnight" ]; then
		AVATAR="$HOME/Videos/goodnight.mp4"
	else
		AVATAR="$HOME/Videos/hibernation.mp4"
	fi

	ffplay -fs -autoexit -ss 0 "$AVATAR" & FIRST_PID=$!
	MAX_WAIT=5
	START_TIME=$(date +%s)
	while true; do
	    # Get the window ID
	    WINDOW_ID=$(xdotool search --pid $FIRST_PID | tail -1)
	    # Check if the window ID is found
	    if [ -n "$WINDOW_ID" ]; then
		sleep 0.5
	        xdotool windowactivate "$WINDOW_ID"
	        EXIT_STATUS=$?

	        if [ "$EXIT_STATUS" -eq 0 ]; then
	                break;
	        else
	        	echo "Window not activated ***********"
	    	fi
	    fi
	    # Check if 3 seconds have passed
	    CURRENT_TIME=$(date +%s)
	    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
	    if [ "$ELAPSED_TIME" -ge "$MAX_WAIT" ]; then
	        break
	    fi
	    # Sleep for a short duration before checking again
	    sleep 0.1
	done

	# Wait for the avatar to finish
	tail --pid=$FIRST_PID -f /dev/null
fi

touch ~/scripts/lasttouch.txt
