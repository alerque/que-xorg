#!/bin/sh

# For some reason SLIM isn't picking up this stuff before executing, so make sure we have a sane environment off the block
source /etc/profile

# Some Xorg init systems don't get this set right, and it's succesfully set differnet ways on different systems
test -n "$HOSTNAME" || HOSTNAME=$(uname -n)
test -n "$HOSTNAME" || HOSTNAME=$(hostname)

# Convenience functions 
hostis() {
	test "$HOSTNAME" = "$1"
	return $?
}

# This stuff gets set on pretty much all systems, so consolidate
myxsets() {
	xhost +

	xset -dpms
	xset s off
	xset s noblank
	xset s 0
	xset b off
	xset r rate 250 50

	xsetroot -solid black
	xsetroot -cursor_name arrow
}

# SLIM calls this script with an argument of the DE chosen at
# the login prompt instead of using xsession files
case $1 in
	awesome|gnome-session|twm)
		DE=$1
		;;
	*)
		DE=awesome
		;;
esac

case $HOSTNAME in
	leylek)
		myxsets
		export SSH_ASKPASS="/usr/libexec/openssh/gnome-ssh-askpass"
		eval $(gnome-keyring-daemon)
		eval $(ssh-agent -s)
		{
		/usr/libexec/gnome-settings-daemon &
		nm-applet --sm-disable &
		bluetooth-applet &
		abrt-applet &
		gnome-sound-applet &
		~/bin/set_background_worldlight.zsh &
		pulseaudio -D
		dropbox start
		ssh-add $HOME/.ssh/id_rsa
		ssh-add $HOME/.ssh/github
		ssh-add $HOME/.ssh/pld
		} &
		exec $DE
		eval $(ssh-agent -k)
		;;
	lemur|pars)
		hostis pars && xrandr --output DVI-I-1 --mode 1920x1080 --pos 0x400 --output VGA-1 --mode 1680x1050 --pos 1920x0 --rotate right
		case $DE in
			gnome-session)
				exec $DE
				;;
			*)
				myxsets
				export SSH_ASKPASS="/usr/lib64/openssh/ssh/ssh-askpass"
				eval $(ssh-agent -s)
				{
				eval $(gnome-keyring-daemon)
				/usr/lib64/gnome-settings-daemon E_SettingsDaemon &
				pulseaudio -D
				dropbox start
				parcellite &
				~/bin/set_background_worldlight.zsh &
				ssh-add ~/.ssh/id_rsa
				ssh-add ~/.ssh/github
				ssh-add ~/.ssh/pld
				} &
				exec $DE
				eval $(ssh-agent -k)
			;;
		esac
		;;
	zebra|crab|octopus|partridge)
		myxsets
		gnome-settings-daemon
		gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
		gnome-power-manager &
		start-pulseaudio-x11
		bluetooth-applet &
		nm-applet --sm-disable &
		#vino-server --sm-disable
		dropbox start -i
		xmodmap .xmodmaprc
		exec $DE
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
		exec $DE
		;;
	*)
		myxsets
		exec $DE || exec twm
		;;
esac
