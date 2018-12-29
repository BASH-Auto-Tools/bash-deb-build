#!/bin/bash
# deb-depends-test.sh

VER="4.0"
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
    echo -e $GREEN" bash $tproc elf-component"$ENDCOLOR
}

testargs()
{
    if [ "+$1" = "+" -o "+$1" = "+-h" -o "+$1" = "+--help" ]
    then
	usage
	exit 0
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="/usr/bin/objdump"
    tdeb="binutils_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/dpkg"
    tdeb="dpkg_*.deb"
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

main()
{
    tlog="$1.depends"
    echo "" > "$tlog"
    echo "$1" >> "$tlog"
    echo "" >> "$tlog"

    objdump -x $1 | grep -w NEEDED | awk '{print $2}' | while read tlib
    do
	echo "Library: $tlib" >> "$tlog"
	dpkg -S $tlib >> "$tlog"
	echo "" >> "$tlog"
    done
}

testargs $1
testcomponent
main $1

#end
