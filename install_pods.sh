#!/bin/sh

# CocoaPods Rome Plugin
# https://github.com/neonichu/Rome
# gem install cocoapods-rome

if [ -f "Podfile.lock" ]; then
	pod update --no-integrate
else
	pod install --no-integrate
fi
