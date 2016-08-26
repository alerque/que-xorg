#!/usr/bin/env zsh

setxkbmap dvp
hash xbacklight || exit
exec sh /usr/share/doc/xss-lock/dim-screen.sh
