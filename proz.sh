#!/bin/bash
# Download songs from 3 site: mp3.zing.vn; nhacso.net; nhaccuatui.com
# Written by: Luoi ST
# Last modified Dec 22,2012 9:20:00
HELP="Usage:\n
wgetvnmusic [option] <URL_link> | -f <input_file>\n
option:\n
-d <destination_directory_to_save>\n
-s: Put each album to one directory\n
-v: Verbose"
function _gcdir() # go/create directory
{
    if [ -d "$1" ]; then
        cd "$1" && return 0
    elif mkdir "$1"; then
        cd "$1" && return 0
    fi
    return 1
} # end function _gcdir

function _get_tui() # Script download songs from nhaccuatui.com
{
#    DM='wget' # download_manager
    #$1 is link song or album
    #$2=['yes' | 'no'] is option tell put each album to one directory
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4 | cut -c6) # song is 'M', album is 'L'
    # Create or change to sub-directory
    if [ "$2" == 'yes' -a "$link_type" == 'L' ]; then
        album_name=$(wget -q -O - $1 |\
sed '/<meta content=\"nghe/s/\(<meta content=\"nghe\)/\n\1/g;s/,/\n/g' |\
grep '<meta content=\"nghe'| cut -c30- | tr ' ' '_' | sed 's/_$//g')
        _gcdir ${album_name}
        [ "$?" -eq 0 ] && change_dir='yes'
    fi
    #Get XML
    source_html=$(wget -q -O - $1)
    if [ "$link_type" == 'M' ]; then
        link_xml=$(echo $source_html | sed '/key2/s/http/\nhttp/g;s/\"/\n/g' |\
grep 'key2' | uniq)
    elif [ "$link_type" == 'L' ]; then
        link_xml=$(echo $source_html | sed '/list2/s/http/\nhttp/g;s/\"/\n/g' |\
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
        $($download_manager $location)
        ((progress++))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_tui

function _get_so() # Script download songs from nhacso.net
{
    DM='wget'
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song:'nghe-nhac', album:'nghe-album'
    # Create or change to sub-directory
    if [ "$2" == 'yes' ]; then
        if [ "$link_type" == 'nghe-album' -o "$link_type" == 'nghe-playlist' ]
        then
            album_name=$(wget -q -O - $1 |\
sed '/<meta name=\"keywords/s/\(<meta name=\"keywords\)/\n\1/g;s/,/\n/g' |\
grep  '<meta name=\"keywords' | cut -d '"' -f4 | tr ' ' '_')
            _gcdir ${album_name}
            [ "$?" -eq 0 ] && change_dir='yes'
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
#        lf=$(echo $location | sed 's/.*\///g') # last field of location
        $($download_manager $location)
#        mv "$lf" "$file_name"
        temp_file=$(ls -t | tail -n 1)
        mv $temp_file ${file_name}.mp3
        ((match_info++))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_so

function _get_zing { # Script download songs from mp3.zing.vn
    DM='wget'
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory
    change_dir='no'
    link_type=$(echo $1 | cut -d '/' -f4) #song is 'bai-hat', album is 'album'
    # Create or change to sub-directory
    if [ "$2" == 'yes' -a "$link_type" == 'album' ]; then
        album_name=$(echo $1 | cut -d '/' -f5)
        _gcdir ${album_name}
        [ "$?" -eq 0 ] && change_dir='yes'
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
        $($download_manager $location)
        temp_file=$(ls -t | tail -n 1)
        mv $temp_file ${file_name}.mp3
        ((progress++))
    done
    [ "$change_dir" == 'yes' ] && cd ..
} # end method _get_zing

function _solve_link { # Recognize music site and download songs
    what_site=$(echo $1 | cut -d '/' -f3)
    case "$what_site" in
        'mp3.zing.vn')
            _get_zing $1 $separate $download_manager;;
        'nhacso.net')
            _get_so $1 $separate $download_manager;;
        'www.nhaccuatui.com')
            _get_tui $1 $separate $download_manager;;
        *)
            echo "We do not support download song for this site: $what_site";;
    esac
} # end method _solve_link

# Begin main
[ "$#" -eq 0 ] && echo -e $HELP && exit 1
# Option variable
is_file='no'  # download with link in 1 file
input_file='' # address of file
des_dir='.'   # directory save songs
separate='no' # each album in new directory (auto create)
input_link='' # address of song (if $is_file == 'no')
download_manager='wget'
echo "========================================================================="
count=1
while [ "$count" -le "$#" ]
do
    arg=$(echo "$@" | cut -d ' ' -f "$count")
    case "$arg" in
        '-f')
            is_file='yes'
            ((count++))
            input_file=$(echo "$@" | cut -d ' ' -f "$count")
            [ ! -f "$input_file" ] && echo "File \"$input_file\"\
not exist, exit script" && exit 2
            echo "Get link song from file \"$input_file\"";;
        '-t')
            ((count++))
            des_dir=$(echo "$@" | cut -d ' ' -f "$count");;
        '-s')
            separate='yes'
            echo 'Each album will be saved separate directory';;
        '-d')
            ((count++))
            download_manager=$(echo "$@" | cut -d ' ' -f ${count});;
        *)
            input_link="$arg"
            echo "Get song from link \"$input_link\"";;
    esac
    ((count++))
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
        ((current_line++))
    done
else
    _solve_link "$input_link"
fi
echo 'Download complete!'
exit 0
