#!/usr/bin/env zsh

setxkbmap dvp
hash xbacklight 2> /dev/null \
	&& exec sh /usr/share/doc/xss-lock/dim-screen.sh \
	|| exec sleep infinity
