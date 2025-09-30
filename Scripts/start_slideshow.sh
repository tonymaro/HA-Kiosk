#!/bin/bash
#
# Start the slideshow app
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

PLAYLIST = "$HOME/Slideshow/halloween/"

export DISPLAY=:0
# make sure screen is on

# Just in case it's already running:
killall mpv
sleep 1
touch ~/scripts/lasttouch.txt

/usr/bin/mpv -fs --shuffle --image-display-duration=240 --loop-playlist $PLAYLIST
exit 0
