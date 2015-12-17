#!/bin/sh

git update-index --assume-unchanged GiveNow/GiveNow/Keys.plist

if [ -f "Keys.local.plist" ]; then
  cp Keys.local.plist GiveNow/GiveNow/Keys.plist
fi

# Undo the change above with the command below
# git update-index --no-assume-unchanged GiveNow/GiveNow/Keys.plist

