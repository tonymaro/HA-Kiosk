#!/bin/bash
#
# Play a random avatar file from a directory, managing window stack
# It prepends "$HOME/Videos/" to the chosen directory name
#
# Example:
# ~/scripts/playavatar.sh "Confirmation"
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

killall mpv
killall ffplay

VID_DIR="$HOME/Videos"

AVATAR_DIR="$VID_DIR/$1"
RANDOM_FILE=$(ls "$AVATAR_DIR" | shuf -n 1)
AVATAR="$AVATAR_DIR/$RANDOM_FILE"

touch ~/scripts/lasttouch.txt

# Start the avatar video
ffplay -fs -autoexit -ss 0 "$AVATAR" & FIRST_PID=$!

# Find the avatar video and pop it to the top
MAX_WAIT=3
START_TIME=$(date +%s)
while true; do
        # Get the window ID
        WINDOW_ID=$(xdotool search --pid $FIRST_PID | tail -1)

        # Check if the window ID is found
        if [ -n "$WINDOW_ID" ]; then
                xdotool windowfocus "$WINDOW_ID"
                EXIT_STATUS=$?

                if [ "$EXIT_STATUS" -eq 0 ]; then
                        break;
                else
                        echo "Window not activated"
                fi
        fi
        # Check if 5 seconds have passed
	CURRENT_TIME=$(date +%s)
	ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
	if [ "$ELAPSED_TIME" -ge "$MAX_WAIT" ]; then
	    break
	fi
    # Sleep for a short duration before checking again
    sleep 0.1
done

# For some reason we have to hide Firefox briefly 
# or this window will never pop to top with some videos
# May be a feature of my crappy hardware, too
wmctrl -r Firefox -b add,hidden
sleep 0.5
wmctrl -r Firefox -b remove,hidden

# Wait for the avatar to finish
wait $FIRST_PID
