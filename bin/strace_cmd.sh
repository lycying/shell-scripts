#!/bin/bash
type strace >/dev/null 2>&1 || { echo >&2 "I require strace but it's not installed.  Aborting."; exit 1; }
:${1?"Usage: strace -c -f -p \$pid couter | strace -f -p \$pid everything"}

strace -c -f -p $1
