#!/bin/sh

set -x

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
	gnome)
		DE=gnome-session
		;;
	awesome|gnome-session|twm)
		DE=$1
		;;
	*)
		DE=awesome
		;;
esac

case $HOSTNAME in
	lemur|pars|jaguar|leylek|karabatak)
		# hostis pars && xrandr --output DVI-I-1 --mode 1920x1080 --pos 0x400 --output VGA-1 --mode 1680x1050 --pos 1920x0 --rotate right
		case $DE in
			gnome-session)
				exec $DE
				;;
			twm)
				myxsets
				exec $DE
				;;
			*)
				myxsets
				test -f /usr/libexec/openssh/gnome-ssh-askpass && export SSH_ASKPASS="/usr/libexec/openssh/gnome-ssh-askpass"
				test -f /usr/lib64/openssh/ssh/ssh-askpass && export SSH_ASKPASS="/usr/lib64/openssh/ssh/ssh-askpass"
				test -f /usr/lib/openssh/ssh/ssh-askpass && export SSH_ASKPASS="/usr/lib/openssh/ssh/ssh-askpass"
				test -f /usr/lib/ssh/ssh-askpass && export SSH_ASKPASS="/usr/lib/ssh/ssh-askpass"
				test -f /usr/lib/ssh/x11-ssh-askpass && export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"
				eval $(ssh-agent -s)
				eval $(gnome-keyring-daemon)
				{
				xmodmap .Xmodmap
				test -f .xmodmaprc-$HOSTNAME && xmodmap .xmodmaprc-$HOSTNAME
				test -f /usr/libexec/gnome-settings-daemon && /usr/libexec/gnome-settings-daemon &
				test -f /usr/lib64/gnome-settings-daemon && /usr/lib64/gnome-settings-daemon E_SettingsDaemon &
				test -f /usr/lib/gnome-settings-daemon && /usr/lib/gnome-settings-daemon E_SettingsDaemon &
				test -f /usr/lib/gnome-settings-daemon/gnome-settings-daemon && /usr/lib/gnome-settings-daemon/gnome-settings-daemon E_SettingsDaemon &
				ssh-add ~/.ssh/id_rsa && ssh-add ~/.ssh/github && ssh-add ~/.ssh/pld &
				sleep 5
				which pulseaudio && pulseaudio -D
				which nm-applet && nm-applet --sm-disable &
				which bluetooth-applet && bluetooth-applet &
				which abrt-applet && abrt-applet &
				which gnome-sound-applet && gnome-sound-applet &
				which parcellite && parcellite &
				which dropboxd && dropboxd &
				which owncloud && owncloud &
				~/bin/set_background_worldlight.zsh &
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
		test -f .xmodmaprc-$HOSTNAME && xmodmap .xmodmaprc-$HOSTNAME
		exec $DE
		;;
	*)
		myxsets
		exec $DE || exec twm
		;;
esac
