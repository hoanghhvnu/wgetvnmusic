#!/bin/bash
# Download songs from 3 site: mp3.zing.vn; nhacso.net; nhaccuatui.com
# Written by: Luoi ST
# Last modified Dec 12,2012 08:00:00
HELP="Usage:\n
$0 <URL_link> | -f <input_file> [option]\n
option:\n
-d <destination_directory_to_save>\n
-s: Put each album to one directory\n"
#Define method
#===============================================================================
# Script download songs from nhaccuatui.com
function _get_tui {
    #$1 is link song or album
    #$2=['yes' | 'no'] is option tell put each album to one directory
    change_dir='no'
    #Check link type (a song or an album)
    link_type=$(echo $1 | cut -d '/' -f4 | cut -c6) # song is 'M', album is 'L'

    # Create or change to sub-directory
    if [ "$2" == 'yes' && "$link_type" == 'L' ]; then
        album_name=$(wget -q -O - $1 |\
sed '/<meta content=\"nghe/s/\(<meta content=\"nghe\)/\n\1/g;s/,/\n/g' |\
grep '<meta content=\"nghe'| cut -c30- | tr ' ' '_' | sed 's/_$//g')
        # Go to sub-directory
        ( [ -d "$album_name" ] && cd "$album_name" && change_dir='yes' ) ||\
        ( mkdir "$album_name" && cd "$album_name" && change_dir='yes' )
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
    list_location=$(wget -q -O - $link |\
sed '/<location>/s/\(<location>\)/\n\1/g;s/\]\]/\n/g'  | grep '<location>' |\
cut -d '[' -f3)
    sum_song=$(echo $list_location | tr ' ' '\n' | wc -l)

    # Start download music
    progress=1
    echo $list_location | tr ' ' '\n' | while read location
    do
        echo "Downloading [progress/$sum_song]"
        wget -q $location
        progress=$(($progress + 1))
    done

    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_tui

#=======================================================================
# Script download songs from nhacso.net
function _get_so {
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory

    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song:'nghe-nhac', album:'nghe-album'

    # Create or change to sub-directory
    if [ "$2" == 'yes' ]; then
        if [ "$link_type" == 'nghe-album' && "$link_type" == 'nghe-playlist' ]
        then
            album_name=$(wget -q -O - $1 |\
sed '/<meta name=\"keywords/s/\(<meta name=\"keywords\)/\n\1/g;s/,/\n/g' |\
grep  '<meta name=\"keywords' | cut -d '"' -f4 | tr ' ' '_')
            # Go to sub-directory
            ( [ -d "$album_name" ] && cd "$album_name" && change_dir='yes' ) ||\
            ( mkdir "$album_name" && cd "$album_name" && change_dir='yes' )
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
        wget -q -O "$file_name.mp3" $location
        match_info=$(($match_info+1))
    done

    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_so

#=======================================================================
# Script download songs from mp3.zing.vn
function _get_zing {
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song is 'bai-hat', album is 'album'

    # Create or change to sub-directory
    if [ "$2" == 'yes' -a "$link_type" == 'album' ]; then
        album_name=$(echo $1 | cut -d '/' -f5)
        # Go to sub-directory
        ( [ -d "$album_name" ] && cd "$album_name" && change_dir='yes' ) ||\
        ( mkdir "$album_name" && cd "$album_name" && change_dir='yes' )
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
        wget -q -O "$song_name.mp3" $location
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
            _get_zing $1 $separate;;
        'nhacso.net')
            _get_so $1 $separate;;
        'www.nhaccuatui.com')
            _get_tui $1 $separate;;
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
            echo "Get link song from file \"$input_file\"";;
        '-d')
            count=$((count + 1))
            des_dir=$(echo "$@" | cut -d ' ' -f "$count");;
        '-s')
            separate='yes'
            echo 'Each album will be saved separate directory';;
        *)
            input_link="$arg"
            echo "Get song from \"$input_link\"";;
    esac
    count=$((count + 1))
done

[ "$is_file" == 'yes' ] && content_file=$(cat $input_file)

# Go to destination directory
( [ -d "$des_dir" ] && cd "$des_dir" && echo "Saving to `pwd`" ) ||\
( mkdir -p "$des_dir" && cd "$des_dir" && echo "Saving to `pwd`" ) ||\
echo -e "Cannot create $des_dir!\n Saving to3 `pwd`"

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