# Written by: Luoi ST
# Last modified: Dec 12,2012 23:12:00
BASH_PROFILE="$HOME/.bash_profile"
[ -f $HOME/.bashrc ] && BASH_PROFILE="$HOME/.bashrc"
if [ "root" == `whoami` ]
then
    BIN_DIR="/usr/local/bin"
    cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    echo "Success installed wgetvnmusic for all user!"
else
    BIN_DIR="$HOME/.bin"
    if [ -d ${BIN_DIR} ]; then
        cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    else
        mkdir -p ${BIN_DIR}
        cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    fi
    echo "export PATH=$PATH:${BIN_DIR}" >> ${BASH_PROFILE}
    echo "Success installed wgetvnmusic!"
fi