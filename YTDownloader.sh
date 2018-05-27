#!/bin/bash
# Author           : Kamil Jędrzejczak
# Created On       : 25.05.2018
# Last Modified By : Kamil Jędrzejczak
# Last Modified On :
# Version          : 1.0
#
# Description      : A simple GUI YouTube downloader in bash.
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


#function to download the movie from YouTube with given URL
function download() {

  wget -q -O- "$URL"	> page.$$
  FILENAME=$(grep "<title>" page.$$ | sed 's|<title>||' | sed 's|</title>.*||')
  URL=$(grep "url=" page.$$ | tr '"' '\n' | grep "url=" | tr '"' '\n' | grep "url=" | sed 's|\\u0026|\n|g' | grep "googlevideo.com" | sed 's|^url=|\n|')
  if [[ $DOWNLOAD_FORMAT == ".mp3" || $DOWNLOAD_FORMAT == ".ogg" || $DOWNLOAD_FORMAT == ".wav" ]]; then
    audio_itag
    if [[ ! -n $DOWNLOAD_URL ]]; then
      video_itag
    fi
  else
    video_itag
  fi
  DOWNLOAD_URL=$(./decoder.pl $DOWNLOAD_URL)
  #wget "$URL" 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --title="Downloading File..."
  (
  echo 0
  wget -q -O- "$DOWNLOAD_URL" --show-progress > "$FILENAME"
  echo 100
  )| zenity --progress --title="$SCRIPT_NAME" --text="Downloading file..."
  if [[ $? != 0 ]]; then
    if [[ -f "$FILENAME" ]]; then
      rm "$FILENAME"
    fi
    zenity --error --text="Error occured\nDid you try to download something you shouldn't?"
  fi

  rm page.$$
  convert_file
}

#function extracting vidID from search query in YouTube
function search() {

  wget -q -O - "http://www.youtube.com/results?search_query="$NAME"" > search.$$
  VID_ID=$(grep -m 1 '/watch?v=' search.$$ | sed 's/.*watch?v=//' | sed 's/".*//')
  URL="http://www.youtube.com/watch?v=$VID_ID"
  rm search.$$
}

#function finding the highest avalaible quality of audio to download
function audio_itag() {
  for itag in "${AUDIO_ITAG[@]}"; do
    DOWNLOAD_URL=$(echo "$URL" | grep "$itag")
    if [[ -n $DOWNLOAD_URL ]]; then
      break
    fi
  done
}

#function finding the highest avalaible quality of video to download
function video_itag() {
  for itag in "${VIDEO_ITAG[@]}"; do
    DOWNLOAD_URL=$(echo "$URL" | grep "$itag")
    if [[ -n $DOWNLOAD_URL ]]; then
      break
    fi
  done
}

#function that converts file and does a little tidying
function convert_file() {
  ffmpeg -i "$FILENAME" "$FILENAME$DOWNLOAD_FORMAT"
  rm "$FILENAME"
}

SCRIPT_NAME="YTDownloader"
MENU=("Download by URL" "Download by name" "Download by vidID" "Choose download format")
AUDIO_ITAG=("itag%3D141" "itag%3D172" "itag%3D140" "itag%3D171" "itag%3D139")
VIDEO_ITAG=("itag%3D37" "itag%3D46" "itag%3D45" "itag%3D22" "itag%3D35" "itag%3D44" "itag%3D34" "itag%3D43" "itag%3D18" "itag%3D5" "itag%3D36" "itag%3D17")
FORMATS=(".fvl" ".mp4" ".avi" ".webm" ".mp3" ".ogg" ".wav")

DOWNLOAD_FORMAT=".mp4"

#main loop of the script
while :
do

  OPTION=$(zenity --list --height 360 --width 450 --text="Choose an option" --title=$SCRIPT_NAME --cancel-label "Exit" --ok-label "OK" --column="Main menu" "${MENU[@]}")

  if [[ $? -eq 1 ]]; then
    break
  fi

  case "$OPTION" in

#download by giving the URL
    "${MENU[0]}" )

      URL_TEMP=$(zenity --entry --title=$SCRIPT_NAME --text="Enter a valid video URL" --height 120)
      URL=$(echo "$URL_TEMP" | sed "s|https://|http://|")
      if [[ "$URL" =~ ^http:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]{11}$ ]]; then
        download
      else
        URL=""
        zenity --error --text="Invalid URL"
      fi
      ;;

#download by giving the name of movie
    "${MENU[1]}" )

      NAME=$(zenity --entry --title=$SCRIPT_NAME --text="Enter a video name to search" --height 120)
      NAME=$(echo $NAME | sed 's/ /+/g')
      NAME=${NAME//[[:blank:]]/}
      if [[ -n $NAME ]]; then
        search
        download
      else
        zenity --error --text="Empty name"
      fi
      ;;

#download by giving the vidID
    "${MENU[2]}" )

    VID_ID=$(zenity --entry --title=$SCRIPT_NAME --text="Enter a valid vidID" --height 120)
    if [[ "$VID_ID" =~ ^[a-zA-Z0-9_-]{11}$ ]]; then
      URL="http://www.youtube.com/watch?v=$VID_ID"
      download
    else
      URL=""
      zenity --error --text="Invalid vidID"
    fi
    ;;

    "${MENU[3]}" )

    DOWNLOAD_FORMAT=$(zenity --list --height 360 --width 450 --text="Choose a desired format" --title=$SCRIPT_NAME --cancel-label "Exit" --ok-label "OK" --column="Format chooser" "${FORMATS[@]}")
    ;;

  esac


done
