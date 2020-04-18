#!/bin/sh
#deb-build.sh

VER="0.5"
DEFPACK="gzip"

tproc=`basename $0`
echo "$tproc version $VER"
echo ""

usage()
{
    tproc=`basename $0`
    echo "usage:"
    echo "  sudo bash $tproc [options]"
    echo " options:"
    echo "  -c [gzip|bzip2|lzma] - compress method"
    echo "  -h - this help"
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
    if [ "+$1" = "+--help" -o "x$1" = "x-h" ]
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

testroot()
{
    if [ "$USER" != "root" ]
    then
        echo "ERROR: You no root!"
        echo ""
        usage
        exit 1
    fi
}

main()
{
    PACK=$DEFPACK
    while getopts ":c:h" opt
    do
        case $opt in
            c) PACK="$OPTARG"
                ;;
            h) usage
                ;;
            *) echo "ERROR: Unknown option -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
    case "$PACK" in
        bzip2) PACKOPT="--bzip2"; PACKSUF="tar.bz2"
            ;;
        lzma) PACKOPT="--lzma"; PACKSUF="tar.lzma"
            ;;
        *) PACK="gzip"; PACKOPT="--gzip"; PACKSUF="tar.gz"
            ;;
    esac
    echo "Compress: $PACK"
    if [ -d "DEBIAN" -a -d "CONTENTS" ]
    then
        mkdir "root"
        cp -r "DEBIAN" "root/DEBIAN"
        cp -r "CONTENTS" "root/CONTENTS"
        cd "root"
        chown -R root *
        chgrp -R root *
        cd "DEBIAN"
        rm -f "md5sums"
        packname="$(grep '^Package:' control | awk '{print $2}')"
        vername="$(grep '^Version:' control | awk '{print $2}')"
        archname="$(grep '^Architecture:' control | awk '{print $2}')"
        debname=$packname"_"$vername"_"$archname".deb"
        echo "$debname"

        cd "../CONTENTS"
        echo "Package: $packname"
        echo ""

        echo "1) Creating checksum..."
        for tdir in *
        do
            if [ -d "$tdir" ]
            then
            find "$tdir" -type f -printf "\"%p\"\n" | xargs md5sum >> "../DEBIAN/md5sums"
            fi
        done
        cat "../DEBIAN/md5sums"
        echo ""

        echo "2) Compress contents of the package..."
        tar -cvf "../data.tar" ./
        echo ""
        echo "SUMMARY:"
        stat -c "%n :  %s" "../data.tar"
        echo ""
        case "$PACK" in
            bzip2) bzip2 -v "../data.tar"
                ;;
            lzma) lzma -v "../data.tar"
                ;;
            *) gzip -v "../data.tar"
                ;;
        esac
        echo ""

        cd "../DEBIAN"
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
            if [ ! -d "DEBIAN" ]
            then
                echo "Not [DEBIAN] packages!"
            fi
            if [ ! -d "CONTENTS" ]
            then
                echo "Not [CONTENTS] packages!"
            fi
    fi
}

testargs "$@"
testcomponent
testroot
main "$@"
goodfinish

#end


