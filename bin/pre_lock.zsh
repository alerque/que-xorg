#!/usr/bin/env zsh

setxkbmap dvp
hash xbacklight || exec sleep infinity
exec sh /usr/share/doc/xss-lock/dim-screen.sh
