#!/usr/bin/env bash

case $1 in

  "help" | "")
    echo -n "
    ██████╗  █████╗ ███████╗██╗  ██╗███████╗██╗     ██╗██╗  ██╗
    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║     ██║╚██╗██╔╝
    ██████╔╝███████║███████╗███████║█████╗  ██║     ██║ ╚███╔╝ 
    ██╔══██╗██╔══██║╚════██║██╔══██║██╔══╝  ██║     ██║ ██╔██╗ 
    ██████╔╝██║  ██║███████║██║  ██║██║     ███████╗██║██╔╝ ██╗
    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═╝

    "
    echo "Video streaming on MacOS and Linux, with subtitles."
    echo
    echo "Syntax: 'bashflix [options] \"query\" [subtitles_language]'"
    echo "options:"
    echo "  update        Update bashflix"
    echo "  previously    Previously watched"
    echo "  select        Select torrent from list"
    echo "  help          See this text"
    echo 
    echo "Tips:"
    echo "  * If the first torrent doesn't work, add 'select' before \"query\" and then select a different torrent;"
    echo "  * Subtitles not synced? Press 'j' to speed it up or 'h' to delay it;"
    echo "  * What did I watch? Type 'bashflix previously' to see which episodes you previoulsy watched;"
    echo "  * Update bashflix from time to time by running 'bashflix update'."
    exit 0
    ;;

  "update")
    $(sudo bash -c "$(curl -s https://raw.githubusercontent.com/0zz4r/bashflix/master/install.sh)")
    echo "Updated!"
    exit 0
    ;;

  "previously")
    echo "Previously watched:"
    echo "$(head ~/bashflix_previously.txt)"
    exit 0
    ;;

  "select")
    query="$2"
    query="${query#\ }"
    query="${query%\ }"
    query="${query// /.}"
    magnet=$(pirate-get -C 'echo "%s"' "${query}" | tail -n 1)
    magnet="${magnet:2}"
    ;;

  *)
    echo "Searching the best torrent..."
    query="$1"
    query="${query#\ }"
    query="${query%\ }"
    query="${query// /.}"
    magnet=$(pirate-get -0 -C 'echo "%s"' "${query}" | tail -n 1)
    ;;
esac

echo "$query" | cat - ~/bashflix_previously.txt > temp && mv temp ~/bashflix_previously.txt
  
if [ -z $magnet ]; then
  echo "Could not find torrent for query ${query}." 
  echo "Please change the query."
  exit 1
else
  echo "Torrent found: ${magnet}"
fi

language=$2
subtitle=""
if [ -n "${language}" ]; then
  echo "Searching the best subtitles..."
  torrent_name_param=$(awk -F "&" '{print $2}' <<< "$magnet")
  torrent_name_dirty=$(awk -F "=" '{print $2}' <<< "$torrent_name_param")
  torrent_name_raw=$(echo "$torrent_name_dirty" | sed -e 's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g')
  torrent_name_escaped=$(echo -e "$torrent_name_raw")
  torrent_name=$(echo -e "$torrent_name_escaped")
  mkdir -p "/tmp/bashflix/${query}"
  languages=("${language}")
  languages+=("en")
  for language in ${languages[@]}; do
    echo "Trying to find subtitles for ${torrent_name} in ${language}"
    subliminal --opensubtitles 0zz4r R4zz0___ download -l "$language" -p opensubtitles -d "/tmp/bashflix/${query}" "${torrent_name}"
    find /tmp/bashflix/${query} -maxdepth 1 -name "*${language}*.srt" | head -1 | xargs -I '{}' mv {} "/tmp/bashflix/${query}/${query}.${language}.srt"
    subtitle=$(find /tmp/bashflix/${query} -maxdepth 1 -name "${query}.${language}.srt" | head -1)
    if [ -n "$subtitle" ]; then
      echo "Found subtitle for language ${language}"
      break;
    fi
  done
fi


if [ -z "${subtitle}" ]; then
  echo "Streaming ${torrent_name}"
  peerflix ${magnet} --mpv -- --fullscreen
else
  echo "Streaming ${torrent_name} with ${subtitle}..."
  peerflix ${magnet} --subtitles ${subtitle} --mpv -- --fullscreen 
fi
