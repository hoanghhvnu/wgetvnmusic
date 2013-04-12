
# Wgetvnmusic

Shell script download automatically music file from three website: 
[Zing mp3][mp3Zing], 
[Nhac so][nhacSo], 
[Nhac cua tui][nhacCuaTui]

[mp3Zing]: http://mp3.zing.vn
[nhacso]: http://nhacso.net
[nhacCuaTui]: http://nhaccuatui.com

# Feature

* Download a song, an album, a playlist or many of them
* Support three biggest music website in Vietnam

# Usage

```
    wgetvnmusic [OPTION]... [FILE]

    OPTION:
    -f <file>
        get link music songs from file instead of URL link
    -t <directory>
        save songs to indicate directory, auto create if not exist
    -s
        each album (playlist) will be saved in separate directory
    -v
        display detail process of script
    -d <command>
        use other download manager (DM) intead of default DM
        (can use with it's opion)
    **!Important:** -d option must be last argument

    FILE:
        is URL link of songs
        OR
        a file which it's content is list of URL link songs
        (when "-f" option to be used)
```

## Installation

```
    git clone https://github.com/luoi/wgetvnmusic
    cd wgetvnmusic/
    chmod +x install.sh
    [sudo] ./install.sh
```

* If run script `install.sh` without `sudo`, wgetvnmusic will be installed for user who ran script.
* If run script with `sudo`, it's installed for all users (just enable for root).

Also use portable:
```
    chmod +x wgetvnmusic.sh
    ./wgetvnmusic.sh

```