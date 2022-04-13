#!/bin/sh

VER=$(git describe --tags --dirty)

(
	cd ..;
	tar -czvf pkg-${VER}.tar.gz pkg
	gpg -v --clear-sign pkg-${VER}.tar.gz
)
