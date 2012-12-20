#!/bin/bash
# Download songs from 3 site: mp3.zing.vn; nhacso.net; nhaccuatui.com
# Written by: Luoi ST
# Last modified Dec 12,2012 19:47:00
HELP="Usage:\n
$0 [option] <URL_link> | -f <input_file>\n
option:\n
-d <destination_directory_to_save>\n
-s: Put each album to one directory\n
-v: Verbose"
# Define method
#===============================================================================
# Script download songs from nhaccuatui.com
function _get_tui {
    #$1 is link song or album
    #$2=['yes' | 'no'] is option tell put each album to one directory
    #$3=[ 'no' | 'verbose' ]
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4 | cut -c6) # song is 'M', album is 'L'
    # Create or change to sub-directory
    if [ "$2" == 'yes' -a "$link_type" == 'L' ]; then
        album_name=$(wget -q -O - $1 |\
sed '/<meta content=\"nghe/s/\(<meta content=\"nghe\)/\n\1/g;s/,/\n/g' |\
grep '<meta content=\"nghe'| cut -c30- | tr ' ' '_' | sed 's/_$//g')
        # Go to sub-directory
        if [ -d "$album_name" ]; then
            cd "$album_name" && change_dir='yes'
        elif mkdir "$album_name"; then
            cd "$album_name" && change_dir='yes'
        fi
    fi
    #Get XML
    if [ "$link_type" == 'M' ]; then
        link_xml=$(wget -q -O - $1 | sed '/key2/s/http/\nhttp/g;s/\"/\n/g' |\
grep 'key2' | uniq)
    elif [ "$link_type" == 'L' ]; then
        link_xml=$(wget -q -O - $1 | sed '/list2/s/http/\nhttp/g;s/\"/\n/g' |\
grep 'list2' | uniq)
    fi
    #Get location to download
    list_location=$(wget -q -O - $link_xml |\
sed '/<location>/s/\(<location>\)/\n\1/g;s/\]\]/\n/g'  | grep '<location>' |\
cut -d '[' -f3)
    sum_song=$(echo $list_location | tr ' ' '\n' | wc -l)
    # Start download music
    progress=1
    echo $list_location | tr ' ' '\n' | while read location
    do
        echo "Downloading [$progress/$sum_song]"
        if [ "$3" == 'verbose' ]; then
            wget $location
        else
            wget -q $location
        fi
        progress=$(($progress + 1))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_tui
#=======================================================================
# Script download songs from nhacso.net
function _get_so {
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory
    #$3=[ 'no' | 'verbose' ]
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song:'nghe-nhac', album:'nghe-album'
    # Create or change to sub-directory
    if [ "$2" == 'yes' ]; then
        if [ "$link_type" == 'nghe-album' -o "$link_type" == 'nghe-playlist' ]
        then
            album_name=$(wget -q -O - $1 |\
sed '/<meta name=\"keywords/s/\(<meta name=\"keywords\)/\n\1/g;s/,/\n/g' |\
grep  '<meta name=\"keywords' | cut -d '"' -f4 | tr ' ' '_')
            # Go to sub-directory
            if [ -d "$album_name" ]; then
                cd "$album_name" && change_dir='yes'
            elif mkdir "$album_name"; then
                cd "$album_name" && change_dir='yes'
            fi
        fi
    fi
    # Get XML
    link_xml=$(wget -q -O - $1 |\
sed '/xmlPath/s/xmlPath/\nxmlPath/g;s/&/\n/g' | grep 'xmlPath' |\
cut -c9- | uniq)
    # Get location to download
    xml=$(wget -q -O - $link_xml)
    list_location=$(echo $xml |\
sed '/<mp3link>/s/\(<mp3link>\)/\n\1/g;s/\]\]/\n/g' | grep '<mp3link>' |\
cut -d '[' -f3)
    list_song_name=$(echo $xml |\
sed '/<songlink>/s/\(<songlink>\)/\n\1/g;s/\]\]/\n/g' | grep '<songlink>' |\
cut -d '[' -f3)
    list_artist=$(echo $xml |\
sed '/<artistlink/s/\(<artistlink>\)/\n\1/g;s/\]\]/\n/g' |\
grep '<artistlink>' | cut -d '[' -f3)
    # Start Download music
    match_info=1
    sum_song=$(echo "$list_location" | tr ' ' '\n' | wc -l )
    echo $list_location | tr ' ' '\n' | while read location
    do
        echo -e "Downloading ($match_info/$sum_song)"
        song_name=$(echo $list_song_name | cut -d ' ' -f $match_info|\
cut -d '/' -f5 | cut -d '.' -f1)
        artist_name=$(echo $list_artist | cut -d ' ' -f $match_info|\
cut -d '/' -f5 | cut -d '.' -f1)
        file_name="$song_name-$artist_name"
        if [ "$3" == 'verbose' ]; then
            wget -O "$file_name.mp3" $location
        else
            wget -q -O "$file_name.mp3" $location
        fi
        match_info=$(($match_info+1))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_so
#=======================================================================
# Script download songs from mp3.zing.vn
function _get_zing {
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory
    #$3=[ 'no' | 'verbose' ]
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song is 'bai-hat', album is 'album'
    # Create or change to sub-directory
    if [ "$2" == 'yes' -a "$link_type" == 'album' ]; then
        album_name=$(echo $1 | cut -d '/' -f5)
        # Go to sub-directory
        if [ -d "$album_name" ]; then
            cd "$album_name" && change_dir='yes'
        elif mkdir "$album_name"; then
            cd "$album_name" && change_dir='yes'
        fi
    fi
    list_location=$(wget -q -O - $1 |\
sed '/download\/song/s/http/\nhttp/g' | sed 's/\"/\n/g' |\
grep 'download/song' | uniq)
    sum_song=$(echo $list_location | tr ' ' '\n' | wc -l)
    # Start Downloading music
    progress=1
    echo $list_location | tr ' ' '\n' | while read location
    do
        echo -e "Downloading ($progress/$sum_song)"
        song_name=$(echo $location | cut -d '/' -f6)
        if [ "$3" == 'verbose' ]; then
            wget -O "$song_name.mp3" $location
        else
            wget -q  $location
        fi
        progress=$(($progress + 1))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_zing
#===============================================================================
# Recognize music site and download songs
function _solve_link {
    what_site=$(echo $1 | cut -d '/' -f3)
    case "$what_site" in
        'mp3.zing.vn')
            _get_zing $1 $separate $verbose;;
        'nhacso.net')
            _get_so $1 $separate $verbose;;
        'www.nhaccuatui.com')
            _get_tui $1 $separate $verbose;;
        *)
            echo "We do not support download song for this site: $what_site";;
    esac
} # end method _solve_link
#===============================================================================
# Begin main
[ "$#" -le 0 ] && echo -e $HELP && exit 1
# Option variable
is_file='no' # download with link in 1 file
input_file='' # address of file
des_dir='.' # directory save songs
separate='no' # each album in new directory (auto create)
input_link='' # address of song (if $is_file == 'no')
verbose='no'
echo "========================================================================="
count=1
while [ "$count" -le "$#" ]
do
    arg=$(echo "$@" | cut -d ' ' -f "$count")
    case "$arg" in
        '-f')
            is_file='yes'
            count=$((count + 1))
            input_file=$(echo "$@" | cut -d ' ' -f "$count")
            [ ! -f "$input_file" ] && echo "File \"$input_file\"\
not exist, exit script" && exit 2
            echo "Get link song from file \"$input_file\"";;
        '-t')
            count=$((count + 1))
            des_dir=$(echo "$@" | cut -d ' ' -f "$count");;
        '-s')
            separate='yes'
            echo 'Each album will be saved separate directory';;
        '-v')
            verbose='verbose';;
        *)
            input_link="$arg"
            echo "Get song from link \"$input_link\"";;
    esac
    count=$((count + 1))
done
[ "$is_file" == 'yes' ] && content_file=$(cat $input_file)
# Go to destination directory
if [ -d "$des_dir" ]; then
    cd "$des_dir" && echo "Saving to `pwd`"
elif mkdir -p "$des_dir"; then
    cd "$des_dir" && echo "Saving to `pwd`"
else
    echo -e "Cannot create $des_dir!\n Saving to `pwd`"
fi
# Get link
if [ "$is_file" == "yes" ]; then
    sum_line=$(echo $content_file | tr ' ' '\n' | wc -l)
    current_line=1
    echo $content_file | tr ' ' '\n' | while read line
    do
        echo "Total ($current_line/$sum_line)"
        _solve_link $line
        current_line=$(($current_line + 1))
    done
else
    _solve_link "$input_link"
fi
echo 'Download complete!'
exit 0
