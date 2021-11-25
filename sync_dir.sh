#!/bin/bash
#GRAFF

echo "`date +%Y-%m-%d\ %H\:%M\:%S`" " Watching $1, syncing with $2"

while true; do
  inotifywait -r -e modify,attrib,close_write,move,create,delete "$1"
  if [ "$(find "$1" -type f | wc -l)" -gt "0" ]; then
    echo "`date +%Y-%m-%d\ %H\:%M\:%S`" ' Change found. Syncing...'
    if [ "$RSYNC_DELETE" = true ]; then
      rsync -aruv --no-perms --no-owner --no-group --delete "$1" "$2" &
    else
      rsync -aruv --no-perms --no-owner --no-group "$1" "$2" &
    fi
    if [ "$HEALTHCHECK_STATE" = true ]; then
      h1=$(find "$1" -type f -print0 | sort -z | xargs -0 sha1sum | cut -d' ' -f1 | sha1sum | cut -d' ' -f1)
      h2=$(find "$2" -type f -print0 | sort -z | xargs -0 sha1sum | cut -d' ' -f1 | sha1sum | cut -d' ' -f1)

      f1=/tmp/"$(echo "$(echo "$1" | sed 's:/*$::')" | md5sum | cut -d' ' -f1)".txt
      f2=/tmp/"$(echo "$2" | md5sum | cut -d' ' -f1)".txt
      echo $h1>"$f1"
      echo $h2>"$f2"
    fi
  fi
done
