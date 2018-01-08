#!/bin/bash
#deb-unpack.sh

VER="0.3"
GREEN="\033[1;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
ENDCOLOR="\033[0m"

tproc=`basename $0`
echo -e $GREEN"$tproc version $VER"$ENDCOLOR
echo ""

usage()
{
    tproc=`basename $0`
    echo -e $YELLOW"usage:"$ENDCOLOR
    echo -e $GREEN"  bash $tproc packet.deb"$ENDCOLOR
    exit 0
}

goodfinish()
{
    echo ""
    echo -e $YELLOW"OK.\n"$ENDCOLOR
    echo ""
}

testargs()
{
    if [ "+$1" = "+" -o "+$1" = "+--help" -o "+$1" = "+-h" ]
    then
	usage
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="/bin/grep"
    tdeb="grep_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/awk"
    tdeb="base_CD1"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/bin/tar"
    tdeb="tar_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/bin/gzip"
    tdeb="gzip_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/md5sum"
    tdeb="coreutils_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/ar"
    tdeb="binutils_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    if [ "+$tnocomp" != "+" ]
    then
        echo -e $RED"Not found $tnocomp !"$ENDCOLOR
	echo ""
	exit 0
    fi
}

testroot()
{
    if [ $USER != root ]
    then
	echo -e $RED"You no root!"$ENDCOLOR
	echo ""
	usage
	exit 0
    fi
}

main()
{
    tdeb="$1"
    if [ -f "$tdeb" ]
    then
	echo "Unpack $tdeb..."
	mkdir -p "config"
	mkdir -p "data"
	echo " config..."
	dpkg -e "$tdeb" "./config"
	echo " data..."
	dpkg -x "$tdeb" "./data"
	echo "OK."
    fi
}

testargs "$@"
testcomponent
#testroot
main "$@"
goodfinish

#end


