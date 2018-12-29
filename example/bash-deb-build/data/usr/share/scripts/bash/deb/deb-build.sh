#!/bin/bash
#deb-build.sh

VER="0.4"
GREEN="\033[1;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
ENDCOLOR="\033[0m"

DEFPACK="gzip"

tproc=`basename $0`
echo -e $GREEN"$tproc version $VER"$ENDCOLOR
echo ""

usage()
{
    tproc=`basename $0`
    echo -e $YELLOW"usage:"$ENDCOLOR
    echo -e $GREEN"  sudo bash $tproc [gzip|bzip2|lzma]"$ENDCOLOR
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
    if [ "+$1" != "+" -a "+$1" != "+gzip" -a "+$1" != "+bzip2" -a "+$1" != "+lzma" ]
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
    tdeb="gawk_*.deb"
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
    if [ "+$1" = "+" ]
    then
	PACK=$DEFPACK
    else
	PACK="$1"
    fi
    if [ "$PACK" = "gzip" ]
    then
	PACKOPT="--gzip"
	PACKSUF="tar.gz"
    fi
    if [ "$PACK" = "bzip2" ]
    then
	PACKOPT="--bzip2"
	PACKSUF="tar.bz2"
    fi
    if [ "$PACK" = "lzma" ]
    then
	PACKOPT="--lzma"
	PACKSUF="tar.lzma"
    fi
    if [ -d "config" -a -d "data" ]
    then
	mkdir "root"
	cp -r "config" "root/control"
	cp -r "data" "root/data"
	cd "root"
	chown -R root *
	chgrp -R root *
	cd "control"
	rm -f "md5sums"
	packname=`grep "^Package:" control | awk '{print $2}'`
	vername=`grep "^Version:" control | awk '{print $2}'`
	archname=`grep "^Architecture:" control | awk '{print $2}'`
	debname=$packname"_"$vername"_"$archname".deb"
	echo "$debname"

	cd "../data"
	echo "Package: $packname"
	echo ""

	echo "1) Compress contents of the package..."
	tar -cvf "../data.tar" ./
	echo ""
	echo "SUMMARY:"
	stat -c "%n :  %s" "../data.tar"
	echo ""
	if [ "$PACK" = "gzip" ]
	then
	    gzip -v "../data.tar"
	fi
	if [ "$PACK" = "bzip2" ]
	then
	    bzip2 -v "../data.tar"
	fi
	if [ "$PACK" = "lzma" ]
	then
	    lzma -v "../data.tar"
	fi
	echo ""

	echo "2) Creating checksum..."
	for tdir in *
	do
	    if [ -d "$tdir" ]
	    then
		find "$tdir" -type f -printf "\"%p\"\n" | xargs md5sum >> "../md5sums"
	    fi
	done
	cat "../md5sums"
	echo ""

	cd ../
	mv -f "md5sums" "control"

	cd control
	echo "3) Compress of a package..."
	tar -czvf "../control.tar.gz" ./
	echo ""

	cd ../
	echo "4) Creating an index version packing deb package..."
	echo "2.0" > "debian-binary"
	cat "debian-binary"
	echo ""

	echo "5) Deb package assembly..."
	ar -qS "$debname" "debian-binary" "control.tar.gz" "data.$PACKSUF"
	cp "$debname" ../
	cd ../
	rm -fr root
	echo ""
    else
	if [ ! -d "config" ]
	then
	    echo "Not [config] packages!"
	fi
	if [ ! -d "data" ]
	then
	    echo "Not [data] packages!"
	fi
    fi
}

testargs "$@"
testcomponent
testroot
main "$@"
goodfinish

#end


