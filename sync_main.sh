#!/bin/bash
#GRAFF

echo "`date +%Y-%m-%d\ %H\:%M\:%S`" " syncing $1/, with $2"
rsync -aruv --no-perms --no-owner --no-group "$1/" "$2"

echo "`date +%Y-%m-%d\ %H\:%M\:%S`" " syncing $2/, with $1"
rsync -aruv --no-perms --no-owner --no-group "$2/" "$1"

/bin/bash /sync/sync_dir.sh "$1/" "$2" &
/bin/bash /sync/sync_dir.sh "$2/" "$1" &

wait
