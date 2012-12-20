function _gcdir {
    if [ -d "$1" ]; then
        cd "$1" && exit 1
    elif mkdir "$1"; then
        cd "$1" && exit 1
    fi
    exit 0
} # end method _gcdir
#echo $(_gcdir $1)
_gcdir $1
echo 'exit status'X
echo $?
