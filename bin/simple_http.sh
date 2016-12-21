#!/bin/sh
: ${1?"Usage: $0 \$port"}
python -m SimpleHTTPServer $1
