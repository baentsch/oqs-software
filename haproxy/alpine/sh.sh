#!/bin/sh

if [ $# -eq 0 ]; then
sh -c sh
else
E="$@"
sh -c "$E"
fi
