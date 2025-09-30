# HA-Kiosk
Scripts and options to run an AI avatar with a dashboard in Kiosk mode on Linux

Shield: [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg

## **NOTE!!!!  I DO NOT PROVIDE SUPPORT FOR THIS CODE, USE AT YOUR OWN RISK** 
If you are unable to make this work, I just plain don't have the time or inclination to assist.  I'm packaging
up what I've created for others to tinker with, not to provide a finished product.

I've tried to add some basic protection so that if your HA instance is compromised they can't use the API to 
take over the kiosk machine as well, but there's no guarantees.  Definitely don't connect the machine running
this code directly to the Internet, or do so at your own risk with the knowledge you'll likely be compromised.

My point being: I didn't spend much time adding any sort of protections or security to this code.  It goes
on the assumption it will only run within a private segregated environment of your house without Internet 
interference.

# What is it?
This project contains a REST API application written in Python, and a series of bash scripts that it calls
to perform various actions.  It's designed to be called by Home Assistant automations to give you more
control over a PC running a dashboard.  The concept is to have a display screen and use automations and HA Voice for control,
not to install a huge touchscreen.

I recommend you do what I do and run the Kiosk machine with this code on a VLAN
that does not have Internet access and can only reach your HA installation and cameras.  It's a best practice to
keep all your IoT on a VLAN.

Also **Be aware there is no authentication on the REST API!!!**  This is another reason to have it on a VLAN.  Feel free to add your
own authentication method if you want authentication on the REST API calls.

# How do I get started?
This expects a few things:
* Home Assistant up and running (duh!  lol)
* A Linux Mint Xfce-based installation.  I chose Xfce due to it being lightweight / smaller and we don't really need much of a desktop GUI.
* Firefox, ffmpeg, and mpv installed on the Linux machine.
* A static private IP on the Linux machine, or a valid internal DNS name that will always reference it.
* A static private IP on the Roku TV that will display the Kiosk.
* Some videos and photos for the AI avatar and slideshow.  I don't supply those.
* Optionally, a window/door contact sensor that works in your HA.  This is used to detect screen orientation.
* A decent amount of both HA and Linux experience.

## Hardware I used:
* A PC.  I used one of these, but notice it's ethernet only, no wifi.  You may need something with wifi:  https://www.amazon.com/dp/B07FKMJGD6
* A wireless HDMI transmitter pair.  I went with 2 receivers:   https://www.amazon.com/dp/B0DKK4ZN44
* A TV mount that rotates:  https://www.amazon.com/dp/B0C3JYPFZF
* A Roku TV.  I'm not thrilled at how thick this one is, but it was cheap and 32": https://www.amazon.com/dp/B0C1J1FS2C
* A window/door contact to detect rotation of the TV:  https://www.amazon.com/dp/B0DMPX7KSQ
* Optionally get a wall outlet kit for giving power without wires showing behind the TV.  If not an electrician, hire one.

## Configuring the Linux PC
I recommend a fresh install of Linux Mint Xfce.  There's a few tweaks to make:
* Setup a single user account on this and configure it to auto-login as that user without a password needed
* DO set a password for the user - that will help protect the "root" access.
* Install the following: 
   `sudo apt-get install ffmpeg mpv firefox`
* Place all the files from this project into the home directory of your user, retaining the folder tree.  Aka, you'll have ~/Scripts/ once done.

### Startup Applications
In the Xfce startup applications (in settings) add the following:
* `~/Scripts/killpanel.sh`  (This gets rid of the Xfce application bar after login.  You may want to wait until everything works right to do this.)
* `~/REST/restserver.sh`
* `/usr/bin/firefox --kiosk https://[your HA instance]:[port]/dashboard-kiosk/`

Feel free to disable any default startup applications of things you won't need.  For instance, I don't need bluetooth.

### Edit the following files
* Modify the ~/Scripts/try_noscreen.sh file to contain the correct IP address of your Roku TV that will run the Kiosk

### Define a couple of items in crontab:
``` crontab
*/15 6-20 * * * ~/Scripts/try_slideshow.sh >/dev/null 2>&1
*/15 21-23,0-5 * * * ~/Scripts/try_noscreen.sh >/dev/null 2>&1
0 6 * * * rm ~/Scripts/nightlight.txt >/dev/null 2>&1
```

### Configure the Roku
Set your Roku TV on a static IP.  Assign the name "Computer" to HDMI1 input (or don't and change the automations.)
Set the options on the Roku to network permissive for control.  Again, having it on a VLAN along with the Kiosk PC is recommended.
Set up the Roku integration in HA.

Feel free to edit that schedule as you see fit.  My Kiosk is configured to turn off at 9PM.  The try_noscreen.sh is simply to ensure that later on if it came back on for some reason it turns itself back off.  The slideshow screensaver is set to run primarily during wake hours.  The nightlight.txt "flag" gets removed at 6AM which is when I have the Kiosk come back on in the mornings.

### Finally, reboot the Kiosk PC

# Setup your scripts and automations in HA
I've tried to put as many of the options and such into HA to make it easier to edit this on the fly without having to restart HA or the like.


## configuration.yaml
You will need to modify your configuration.yaml file on the HA server to add the following code.  Substitute the IP address of the new Linux Kiosk PC:

```yaml
rest_command:
  kiosk_rest:
    url: "http://[kiosk-pc]:5000/run/{{script}}"
    method: post
    headers:
      user-agent: "Mozilla/5.0 {{useragent }}"
    content_type: 'application/json; charset=utf-8'
    payload: '{"args":["{{args1}}","{{args2}}"]}'
```

***NOTE: I couldn't ever get the REST payload working as a proper array passed from an automation so I hard-coded in two arguments that get inserted into the JSON.  Someone with more smartness than me is welcome to let me know the proper way to do that and I'll happily update this.***

Now, restart your Home Assistant server or otherwise reload your configuration.

## Helper script for the TV control
You'll need to 

## Configure a few automations
Here's some example YAML, but you can use the GUI entirely for configuration except for when entering the REST API call parameters:

First, this works from my Amcrest integration when the doorbell sees a human being.  You will need to supply your own RTSP URL for your front door camera to use this.
It also uses a notification group I created called "notify_tony" that points to my current cellphone for pinging it as well.  More an example than anything you could copy/paste and use:
```yaml
alias: Doorbell Human
description: ""
triggers:
  - entity_id:
      - binary_sensor.doorbell_human
      - camera.doorbell
    to: "on"
    from: "off"
    trigger: state
conditions: []
actions:
  - action: script.ensure_kiosk_on_input
    metadata: {}
    data: {}
  - action: rest_command.kiosk_rest
    metadata: {}
    data:
      script: playstream
      args1: Door
      args2: rtsp://[username]:[password]@[nvr-ip-address]:[port]/rtsp/streaming?channel=02
  - action: notify.notify_tony
    data:
      message: Human detected
      data:
        channel: Motion
        ttl: 0
        priority: high
```
