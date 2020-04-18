#!/bin/sh
# deb-depends-test.sh

VER="5.0"

tproc=`basename $0`
echo "$tproc version $VER"
echo ""

usage()
{
    tproc=`basename $0`
    echo "usage:"
    echo " sh $tproc elf-component"
}

testargs()
{
    if [ "x$1" = "x" -o "x$1" = "x-h" -o "x$1" = "x--help" ]
    then
		usage
		exit 0
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="objdump"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    tcomp="dpkg"; [ $(which $tcomp) ] || tnocomp="$tnocomp $tcomp"
    if [ "x$tnocomp" != "x" ]
    then
        echo "ERROR: Not found $tnocomp !"
        echo ""
        exit 1
    fi
}

main()
{
	telf="$1"
    tlog="$telf.depends"
    echo "" > "$tlog"
    echo "$telf" >> "$tlog"
    echo "" >> "$tlog"

    objdump -x "$telf" | grep -w NEEDED | awk '{print $2}' | while read tlib
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
