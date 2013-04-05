# Introduction

**Wgetvnmusic** is a shell script help you download song from three site:  
[Zing mp3][mp3Zing]  
[Nhac so][nhacSo]  
[Nhac cua tui][nhacCuaTui]  

[mp3Zing]: http://mp3.zing.vn
[nhacso]: http://nhacso.net
[nhacCuaTui]: http://nhaccuatui.com

## Installation
Clone this repository somewhere  

    $ git clone https://github.com/luoi/wgetvnmusic  

**Use once time:**  
` chmod +x wgetvnmusic.sh`  

**Use many times:**  
You must install them into your path, for each user or all user  
***For each user:***  
Copy file wgetvnmusic into your home directory:  
` cp wgetvnmusic.sh $HOME/.wgetvnmusic/wgetvnmusic`  

Change modify access for it:  
` chmod +x $HOME/.wgetvnmusic/wgetvnmusic`  

Export $PATH variable:  
` echo "\$PATH=${PATH};$HOME/.wgetvnmusic" >> $HOME/.bash_profile`  

Ok, enjoy it.  
***For all user (you must switch to root user):***  
Copy file wgetvnmusic into System path:  
` cp wgetvnmusic.sh /usr/bin/wgetvnmusic`  

Change modify access:  
` chmod +x /usr/bin/wgetvnmusic`  

Ok, you are done.  
  
## Syntax to use  
./wgetvnmusic <URL link> | -f < input file has link> [option]  
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
