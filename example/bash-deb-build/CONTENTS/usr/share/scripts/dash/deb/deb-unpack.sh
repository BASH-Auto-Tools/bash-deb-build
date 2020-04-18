#!/bin/sh
#deb-unpack.sh

VER="0.5"

tproc=`basename $0`
echo "$tproc version $VER"
echo ""

usage()
{
    tproc=`basename $0`
    echo "usage:"
    echo "  bash $tproc packet.deb"
    exit 0
}

goodfinish()
{
    echo ""
    echo "OK.\n"
    echo ""
}

testargs()
{
    if [ "x$1" = "x" -o "x$1" = "x--help" -o "x$1" = "x-h" ]
    then
        usage
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="grep"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="awk"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="tar"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="ar"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="gzip"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="md5sum"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    if [ "x$tnocomp" != "x" ]
    then
        echo "ERROR: Not found $tnocomp !"
        echo ""
        exit 1
    fi
}

main()
{
    tdeb="$1"
    if [ -f "$tdeb" ]
    then
        echo "Unpack $tdeb..."
        mkdir -p "DEBIAN"
        mkdir -p "CONTENTS"
        echo " DEBIAN..."
        dpkg -e "$tdeb" "./DEBIAN"
        echo " CONTENTS..."
        dpkg -x "$tdeb" "./CONTENTS"
        echo "OK."
    fi
}

testargs "$@"
testcomponent
main "$@"
goodfinish

#end


