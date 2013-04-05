# Introduction

**Wgetvnmusic** is a script help you download song from 3 site:
[Zing mp3][mp3Zing]
[Nhac so][nhacSo]
[Nhac cua tui][nhacCuaTui]

[mp3Zing]: http://mp3.zing.vn
[nhacso]: http://nhacso.net
[nhacCuaTui]: http://nhaccuatui.com

## How to use
First, change permission access to wgetvnmusic.sh
code: chmod +x wgetvnmusic.sh

## Syntax to use
./wgetvnmusic <URL link> | -f <input file has link> [option]
: URL link is address to listen music
-f <file1>: content of file1 is many URL link, separate by linefeed
option:
-t <desDir>: songs will be saved to directory desDir, if not exist, create it.
-s: option tell that put each album to one directory named by album name.
-v: verbose (only use without -d option)
-d <download_manager>: choose download_manager to download songs

!Important: -d option must be last argument
Author: LuoiST
Email: faithonour@gmail.com
