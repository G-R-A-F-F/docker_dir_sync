#!/bin/bash
#GRAFF

function comparedate() {
    if [ ! -f "$1" ]; then
        # echo "file $1 does not exist"
        return 1
        # exit 1
    fi
    MAXAGE=$(bc <<< '1*60*60') # seconds in 1 hour
    # file age in seconds = current_time - file_modification_time.
    FILEAGE=$(($(date +%s) - $(stat -c '%Y' "$1")))
    test $FILEAGE -lt $MAXAGE && {
        # echo "$1 is less than 1 hour old."
        return 0
    }
    # echo "$1 is older than 1 hour."
    rm "$1"
    return 1
}
# set defaults for the passed arguments (if any) if not defined.
arg1=${1:-"/sync/data/A"}
arg2=${2:-"/sync/data/B"}
set -- "${arg1}" "${arg2}"
unset arg1 arg2

f1=/tmp/"$(echo "$1" | md5sum | cut -d' ' -f1)".txt
f2=/tmp/"$(echo "$2" | md5sum | cut -d' ' -f1)".txt
comparedate "$f1"
comparedate "$f2"

if [ -f "$f1" ]; then
    h1=$(cat "$f1")
    # echo "using cache" $f1
else
    h1=$(find "$1" -type f -print0 | sort -z | xargs -0 sha1sum | cut -d' ' -f1 | sha1sum | cut -d' ' -f1)
    echo $h1>"$f1"
fi
if [ -f "$f2" ]; then
    h2=$(cat "$f2")
    # echo "using cache" $f2
else
    h2=$(find "$2" -type f -print0 | sort -z | xargs -0 sha1sum | cut -d' ' -f1 | sha1sum | cut -d' ' -f1)
    echo $h2>"$f2"
fi
echo "$h1"
echo "$h2"

if [ "$h1" == "$h2" ]; then
    # echo "Strings are equal"
    exit 0
else
    # echo "Strings are not equal"
    rm "$f1"
    rm "$f2"
    exit 1
fi
