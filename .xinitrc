#!/bin/sh

xhost +

xset -dpms
xset s off
xset s noblank
xset s 0
xset b off
xset r rate 250 50

xsetroot -solid black
xsetroot -cursor_name arrow

case $(hostname) in
	laylek)
		;;
	zebra|crab|octopus|partridge)
		set -x
		gnome-settings-daemon
		gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
		gnome-power-manager &
		start-pulseaudio-x11
		bluetooth-applet &
		nm-applet --sm-disable &
		#vino-server --sm-disable
		dropbox start -i
		xmodmap .xmodmaprc
		exec awesome
		;;
	lemur|pars)
		/usr/lib64/gnome-settings-daemon E_SettingsDaemon &
		pulseaudio -D
		eval `ssh-agent -s`
		sleep 1
		#urxvt -e ssh-add ~/.ssh/id_rsa
		#ssh camelion -D localhost:8080 &
		dropbox start -i
		xmodmap -e keycode\ 48\ \=\ apostrophe\ quotedbl
		xmodmap ~/.xmodmaprc
		exec awesome
		;;
	ibex)
		/usr/lib/gnome-settings-daemon E_SettingsDaemon &
		gnome-keyring-daemon -s -d -c pkcs11,secrets,ssh
		nm-applet -sm-disable &
		bluetooth-applet &
		pactl load-module module-alsa-sink device=bluetooth
		syndaemon -i .5 -t -d
		synclient VertEdgeScroll=0 VertTwoFingerScroll=1 HorizTwoFingerScroll=1 ClickFinger1=1 ClickFinger2=3 ClickFinger3=3 TapButton1=1 TapButton2=2 TapButton3=3
		xmodmap .xmodmaprc
		#feh --bg-center Desktop/sunset_bg.jpg
		dropbox start -i
		exec awesome
		;;
	*)
		exec twm
		;;
esac
