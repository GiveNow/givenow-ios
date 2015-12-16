#!/bin/sh

if [ -f "Podfile.lock" ]; then
	pod update --no-integrate
else
	pod install --no-integrate
fi
