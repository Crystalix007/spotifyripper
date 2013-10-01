#!/bin/bash

if [[ -z $1 ]]; then
  musicdir="."
else
  musicdir=$1
fi

./notify.sh | while read line
do
  if [[ $line == "__SWITCH__" ]]; then
    killall pacat 2> /dev/null
    if [[ -n $title ]]; then
      vorbiscomment -a tmp.ogg -t "ARTIST=$artist" -t "ALBUM=$album"\
          -t "TITLE=$title"
      saveto="$musicdir/$artist/$album/$title.ogg"
      echo "Saved song $title by $artist to $saveto"
      if [[ ! -a "$artist/$album" ]]; then
        mkdir -p "$artist/$album"
      fi
      mv tmp.ogg "$saveto"
    fi
    echo "RECORDING"
    pacat --record -d 1 | oggenc -b 192 -o tmp.ogg --raw - 2>/dev/null &
  else
    variant=$(echo "$line"|cut -d= -f1)
    string=$(echo "$line"|cut -d= -f2)
    if [[ $variant == "artist" ]]; then
      artist="$string"
    elif [[ $variant == "title" ]]; then
      title="$string"
    elif [[ $variant == "album" ]]; then
      album="$string"
    fi
  fi
done