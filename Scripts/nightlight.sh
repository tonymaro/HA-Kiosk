#!/bin/bash
#
# Go into nightlight mode, playing a specific slideshow
# Don't turn off the screen anymore at night
# A crontab event should remove this flag in the morning
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

# Interrupt anything playing
killall ffplay
killall mpv

SLIDESHOW="$HOME/Slideshow/nightlight/"
AVATAR="$HOME/Videos/nightlight.mp4"

ffplay -fs -autoexit "$AVATAR" & FIRST_PID=$!

sleep 1.5;
xdotool windowfocus `xdotool search --pid $FIRST_PID | tail -1`

# Wait for the avatar to finish
tail --pid=$FIRST_PID -f /dev/null

# Set the flags
touch ~/scripts/nightlight.txt
touch ~/scripts/lasttouch.txt

# Start the slideshow
/usr/bin/mpv -fs --shuffle --image-display-duration=240 --loop-playlist $SLIDESHOW &
