#!/bin/bash
#
# Given a parameter choose and play an intro avatar video followed by camera stream
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

# Script safety checks:
param_count=$#
if [ $param_count -lt 1 ]; then
	echo "You must provide the category of videos to play as a parameter, along with a camera stream"
	echo "Example:   ./choosestream.sh Door rtsp://stream:stream123@192.168.5.5:80/rtsp/streaming?channel=02"
	echo "The avatar video gets chosen from ~/Videos/Door in this case."
	exit
fi

# Where we store the video directories:
VID_DIR="$HOME/Videos"

STREAM="$2" # Second parameter

AVATAR_DIR="$VID_DIR/$1"
RANDOM_FILE=$(ls "$AVATAR_DIR" | shuf -n 1)
AVATAR="$AVATAR_DIR/$RANDOM_FILE"

touch ~/scripts/lasttouch.txt

# Call the streaming script to process the selection
~/scripts/playstream.sh "$AVATAR" "$STREAM" 20
