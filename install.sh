# Written by: Luoi ST
# Date create: Dec 12, 2012
# Last modified: Apr 12, 2013 16:48
BASH_PROFILE="$HOME/.bash_profile"
[ -f $HOME/.bashrc ] && BASH_PROFILE="$HOME/.bashrc"
if [ "root" == `whoami` ]
then
    BIN_DIR="/usr/local/bin"
    cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    echo "Success installed \"wgetvnmusic\" for all user!"
    echo "Run \"wgetvnmusic\" to print help (without quote)"
else
    BIN_DIR="$HOME/.local/bin"
    if [ -d ${BIN_DIR} ]; then
        cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    else
        mkdir -p ${BIN_DIR}
        cp wgetvnmusic.sh "${BIN_DIR}/wgetvnmusic"
    fi
    echo "export PATH=$PATH:${BIN_DIR}" >> ${BASH_PROFILE}
    echo "Success installed \"wgetvnmusic\" for only you!"
    echo "Must logout or reboot your system to use them!"
    echo "After, Run \"wgetvnmusic\" to print help (without quote)"
    echo "TIP: Run script \"install\" file as root user to \
use \"wgetvnmusic\" immediate!"

fi
