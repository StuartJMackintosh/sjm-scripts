#!/bin/bash

# TODO: Check jhead exists
# Ask to set tags first

MOVEDATE=`date +%Y%m%d%H%M%S`

LOGFILE="move-image-${MOVEDATE}.log"

echo "Logging to $LOGFILE"

jhead -n../%Y%m%d/%Y%m%d-%H%M%S * >>$LOGFILE


