#!/bin/bash
#
# Start a camera stream and overlay an avatar intro video, siwtching
# to the camera when it finishes
#
# Call this from another script, passing the AVATAR file, CAMERA URL, and time in seconds to show camera as parameters
#
# Example:
# ~/scripts/playstreamwithintro.sh "$HOME/Videos/doorbell.mp4" "rtsp://[username]:[password]@[ipaddress]:[port]/rtsp/streaming?channel=02" 20
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

AVATAR=$1
CAMERA=$2
DURATION=$3

# Start the camera stream forked - takes about 3 seconds to launch
ffplay -fs -an "$CAMERA" & STREAM_PID=$!
# Start the avatar video
ffplay -fs -autoexit -ss 0 "$AVATAR" & FIRST_PID=$!

# Find the avatar video and pop it to the top
MAX_WAIT=5
START_TIME=$(date +%s)
sleep 0.2
while true; do
        # Get the window ID
        WINDOW_ID=$(xdotool search --pid $FIRST_PID | tail -1)
	sleep 0.1
        # Check if the window ID is found
        if [ -n "$WINDOW_ID" ]; then
                xdotool windowfocus $WINDOW_ID
                EXIT_STATUS=$?
                if [ "$EXIT_STATUS" -eq 0 ]; then
                        break;
                else
                        echo "Window not activated ***********"
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

# Hide firefox to eliminate flicker when switching to video stream
sleep 0.5
wmctrl -r Firefox -b add,hidden

# Wait for the avatar to finish
wait $FIRST_PID

# Make sure the camera stream pops to top
xdotool windowfocus `xdotool search --pid $STREAM_PID | tail -1`
sleep 3
# Show firefox again
wmctrl -r Firefox -b remove,hidden
# Let camera show for 20 seconds
sleep $DURATION
killall ffplay
