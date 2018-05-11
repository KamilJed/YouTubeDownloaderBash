#!/bin/bash


SCRIPT_NAME="YTDownloader"
MENU=("Download by URL" "Download by name" "Download by vidID")

while :
do

  OPTION=$(zenity --list --height 360 --width 450 --text="Choose an option" --title=$SCRIPT_NAME --cancel-label "Exit" --ok-label "OK" --column="Main menu" "${MENU[@]}")

  if [[ $? -eq 1 ]]; then
    break
  fi

  case "$OPTION" in

    "${MENU[0]}" )

      echo 0
      ;;

    "${MENU[1]}" )

      echo 1
      ;;

    "${MENU[2]}" )

    echo 2
    ;;

  esac


done
