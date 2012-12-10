#!/bin/bash
# Download songs from 3 site: mp3.zing.vn; nhacso.net; nhaccuatui.com
# Luoi ST
# Last modified Dec 2,2012 21:40:00

#Define method
#===============================================================================
# Script download songs from nhaccuatui.com
getTui(){
    #$1 is link song or album
    #$2=['yes' | 'no'] is option tell put each album to one directory

    #Check link type (a song or an album)
    linkType=$(echo $1 | cut -d '/' -f4 | cut -c6) # song is 'M', album is 'L'
    #chageDir variable check when current directory change
    changeDir='no'

    # Create or change to sub-directory
    if [ "$2" == 'yes' ] ; then
        if [ "$linkType" == 'L' ] ; then
            #get albumName
            albumName=$(wget -q -O - $1 |\
sed '/<meta content=\"nghe/s/\(<meta content=\"nghe\)/\n\1/g;s/,/\n/g' |\
grep '<meta content=\"nghe'| cut -c30- | tr ' ' '_' | sed 's/_$//g')
            # Go to sub-directory
            if [ -d "$albumName" ] ; then
                if cd "$albumName" ; then
                    changeDir='yes'
                fi
            else
                mkdir "$albumName"
                cd "$albumName"
                changeDir='yes'
            fi
        fi
    fi

    #Get XML
    if [ "$linkType" == 'M' ] ; then
        link=$(wget -q -O - $1 | sed '/key2/s/http/\nhttp/g;s/\"/\n/g' |\
grep 'key2' | uniq)
    elif [ "$linkType" == 'L' ] ; then
        link=$(wget -q -O - $1 | sed '/list2/s/http/\nhttp/g;s/\"/\n/g' |\
grep 'list2' | uniq)
    fi

    #Get location to download
    listLocation=$(wget -q -O - $link |\
sed '/<location>/s/\(<location>\)/\n\1/g;s/\]\]/\n/g'  | grep '<location>' |\
cut -d '[' -f3)
    # Count total location
    sumSong=$(echo $listLocation | tr ' ' '\n' | wc -l)
    #Bien chua thong tin dang tai den bai thu may
    progress=1

    # Bat dau tai nhac
    echo $listLocation | tr ' ' '\n' | while read location
    do
        echo -e "Downloading ($progress/$sumSong) (in this Album)"
        wget -q $location
        progress=$(($progress + 1))
    done

    #Sau khi tai xong tro ve thu muc truoc neu thu muc hien tai da duoc thay doi
    if [ "$changeDir" == 'yes' ] ; then
        cd ..
    fi
} # end method getTui

#=======================================================================
# Script download songs from nhacso.net
getSo(){
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory

    #check link (a song or an album)
    linkType=$(echo $1 | cut -d '/' -f4) #song:'nghe-nhac', album:'nghe-album'
    changeDir='no'

    # Create or change to sub-directory
    if [ "$2" == 'yes' ] ; then
        if [ "$linkType" == 'nghe-album' -o "$linkType" == 'nghe-playlist' ]
        then
            # Get albumName
            albumName=$(wget -q -O - $1 |\
sed '/<meta name=\"keywords/s/\(<meta name=\"keywords\)/\n\1/g;s/,/\n/g' |\
grep  '<meta name=\"keywords' | cut -d '"' -f4 | tr ' ' '_')
            # Go to sub-directory
            if [ -d "$albumName" ] ; then
                if cd "$albumName" ; then
                    changeDir='yes'
                fi
            else
                mkdir "$albumName"
                cd "$albumName"
                changeDir='yes'
            fi
        fi
    fi

    # Get XML
    link=$(wget -q -O - $1 |\
sed '/xmlPath/s/xmlPath/\nxmlPath/g;s/&/\n/g' | grep 'xmlPath' |\
cut -c9- | uniq)

    # Get location to download
    xml=$(wget -q -O - $link)
    listLocation=$(echo $xml |\
sed '/<mp3link>/s/\(<mp3link>\)/\n\1/g;s/\]\]/\n/g' | grep '<mp3link>' |\
cut -d '[' -f3)
    listSongName=$(echo $xml |\
sed '/<songlink>/s/\(<songlink>\)/\n\1/g;s/\]\]/\n/g' | grep '<songlink>' |\
cut -d '[' -f3)
    listArtist=$(echo $xml |\
sed '/<artistlink/s/\(<artistlink>\)/\n\1/g;s/\]\]/\n/g' |\
grep '<artistlink>' | cut -d '[' -f3)

    # So thu tu de lam viec voi tung link
    matchInfo=1
    sumSong=$(echo "$listLocation" | tr ' ' '\n' | wc -l )
    echo $listLocation | tr ' ' '\n' | while read location
    do
        echo -e "Downloading ($matchInfo/$sumSong) (in this Album)"
        songName=$(echo $listSongName | cut -d ' ' -f $matchInfo|\
cut -d '/' -f5 | cut -d '.' -f1)
        artistName=$(echo $listArtist | cut -d ' ' -f $matchInfo|\
cut -d '/' -f5 | cut -d '.' -f1)
        fileName="$songName-$artistName"
        wget -q -O "$fileName.mp3" $location
        matchInfo=$(($matchInfo+1))
    done

    # Tro ve thu muc truoc neu thu muc da bi thay doi
    if [ "$changeDir" == 'yes' ] ; then
        cd ..
    fi
} # end method getSo

#=======================================================================
# Script download songs from mp3.zing.vn
getZing(){
    #$1 is link song or album
    #$2=['yes' | 'no' ] is option tell put each album to one directory, 
    #check link (a song or an album)
    linkType=$(echo $1 | cut -d '/' -f4) #song is 'bai-hat', album is 'album'
    changeDir='no'

    # Create or change to sub-directory
    if [ "$2" == 'yes' ] ; then
        if [ "$linkType" == 'album' ] ; then
            #get albumName
            albumName=$(echo $1 | cut -d '/' -f5)
            # Go to sub-directory
            if [ -d "$albumName" ] ; then
                if cd "$albumName" ; then
                    changeDir='yes'
                fi
            else
                mkdir "$albumName"
                cd "$albumName"
                changeDir='yes'
            fi
        fi
    fi

    #get link song
    listLocation=$(wget -q -O - $1 |\
sed '/download\/song/s/http/\nhttp/g' | sed 's/\"/\n/g' |\
grep 'download/song' | uniq)
    sumSong=$(echo $listLocation | tr ' ' '\n' | wc -l)

    # Bat dau tai nhac
    progress=1
    echo $listLocation | tr ' ' '\n' | while read location
    do
        echo -e "Downloading ($progress/$sumSong) (in this Album)"
        #get songName
        songName=$(echo $location | cut -d '/' -f6)
        wget -q -O "$songName.mp3" $location
        progress=$(($progress + 1))
    done

    # Neu thu muc da bi thay doi thi tro ve thu muc truoc
    if [ "$changeDir" == 'yes' ] ; then
        cd ..
    fi
} # end method getZing

#===============================================================================
# Ham phan biet trang web va tai nhac
solveLink(){
    whatSite=$(echo $1 | cut -d '/' -f3)
    if [ "$whatSite" == 'mp3.zing.vn' ] ; then
        getZing $1 $separate
    elif [ "$whatSite" == 'nhacso.net' ] ; then
        getSo $1 $separate
    elif [ "$whatSite" == 'www.nhaccuatui.com' ] ; then
        getTui $1 $separate
    fi
} # end method solveLink

#===============================================================================
# Bat dau chuong trinh chinh
# Option variable
isFile='no' # download with link in 1 file
inputFile='' # address of file
desDir='.' # directory save songs
separate='no' # each album in new directory (auto create)
inputLink='' # address of song (if $isFile == 'no')

# Check option
#ofFile='no' # De biet o luot nay gia tri la file dau vao
#ofDir='no' # De biet luot nay gia tri la cua $desDir
#for i in $1 $2 $3 $4 $5 $6 $7 $8 $9
#do
#    if [ "$i" != "" ] ; then
#        if [ "$ofFile" == 'yes' ] ; then
#            inputFile="$i"
#            ofFile='set'
#        elif [ "$ofDir" == 'yes' ] ; then
#            desDir="$i"
#            ofDir='set'
#        elif [ "$i" == '-f' ] ; then
#            isFile='yes'
#            ofFile='yes' # get value in next loop
#        elif [ "$i" == '-d' ] ; then
#            ofDir='yes'
#        elif [ "$i" == '-s' ] ; then
#            separate='yes'
#        else
#            inputLink="$i"
#        fi
#    fi
#done
#-------------------------------------------------------------------------------
arg=1
while [ "$arg" -le "$#" ]
do
    i=$(echo "$@" | cut -d ' ' -f "$arg")
    if [ "$i" != "" ] ; then
        if [ "$i" == '-f' ] ; then
            isFile='yes'
            arg=$((arg + 1))
            inputFile=$(echo "$@" | cut -d ' ' -f "$arg")
        elif [ "$i" == '-d' ] ; then
            arg=$((arg + 1))
            desDir=$(echo "$@" | cut -d ' ' -f "$arg")
        elif [ "$i" == '-s' ] ; then
            separate='yes'
        else
            inputLink="$i"
        fi
    fi
    arg=$((arg + 1))
done # end while stament
#-------------------------------------------------------------------------------



# bien chua noi dung file input
if [ "$isFile" == 'yes' ] ; then
    contentFile=$(cat $inputFile)
fi

# go to destination directory
if [ -d "desDir" ] ; then
    if cd "$desDir" ; then
        echo "Current directory is $desDir"
    fi
else
    if mkdir -p "$desDir" ; then
        cd "$desDir"
    else
        echo "Cannot create $desDir!"
    fi
    echo "Current directory is $desDir"
fi

# Get link
if [ "$isFile" == "yes" ] ; then
    sumLine=$(echo $contentFile | tr ' ' '\n' | wc -l)
    currentline=1
    echo $contentFile | tr ' ' '\n' | while read line
    do
        # xu li, goi cac ham
        echo "Total ($currentline/$sumLine)"
        solveLink $line
        currentline=$(($currentline + 1))
    done
else
    solveLink "$inputLink"
fi
echo 'Download complete!'