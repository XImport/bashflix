# bashflix 🍿
Video streaming on MacOS and Linux, with subtitles 🎥

![](https://media.giphy.com/media/mACRrW4R25kuQLexXn/giphy.gif)

# How to use
1. Open terminal app 💻
2. Type `bashflix "query" [subtitles_language]` ⌨️
3. Wait a few seconds for the magic to happen 🪄✨ 

## Examples:
```
bashflix "movie 1080p"
```
```
bashflix "serie s01e01" en
```

# How to install
1. Open terminal app 💻
2. (MacOS) Install Homebrew and update Bash by running: 🍺
``` 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && brew install bash
```
3. Run install script: 🏃‍♀️ 
```
sudo bash -c "$(curl -s https://raw.githubusercontent.com/XImport/bashflix/master/install.sh)"
```
4. (Optional) [Change DNS to 1.1.1.1](https://1.1.1.1/dns/) to prevent torrent search failures 😵

# Tips
* If the first torrent doesn't work, add `select` before `"query"` and then select a torrent from the list;
* Subtitles not synced? Press `j` to speed it up or `h` to delay it;
* What did I watch? Type `bashflix previously` to see which episodes you previoulsy watched;
* Update bashflix from time to time by running `bashflix update`.

# Powered by
[**pirate-get**](https://github.com/vikstrous/pirate-get) for torrent search, [**peerflix**](https://github.com/mafintosh/peerflix) and [**vlc**](https://github.com/videolan/vlc) for torrent streaming and playing,  and [**subliminal**](https://github.com/Diaoul/subliminal) to download subtitles.

# Disclaimer
bashflix is under development. If you want the newer features or bugs fixed, run `bashflix update` from time to time. Some torrents (and subtitles), specially older ones, will not be found or will have few peers, which will make the video stop multiple times. Sometimes, waiting a bit for the video to download works. Downloading files via torrents might be illegal, depending on the content, so be aware of copyright infringements. Use a VPN for privacy.

# License
This project is licensed under the terms of the [MIT license](https://github.com/0zz4r/bashflix/blob/master/LICENSE.md).
