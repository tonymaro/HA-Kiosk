#!/bin/bash
#
# Kill the Xfce panel after 10 seconds
# Set this in your startup apps at login
#
######################################

export DISPLAY=:0
sleep 10
xfce4-panel -q
