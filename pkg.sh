#!/bin/sh -e

prog="$1"; shift
vers="$1"; shift
file="$1"; shift
tdir=/tmp/beanstalk-pkg.$$.d
pfx="$prog-$vers"

cleanup() {
    rm -rf $tdir
}

trap cleanup EXIT

mkdir -p $tdir

git-archive --format=tar --prefix="$pfx/" "v$vers" > $tdir/p.tar

# Replace version.h with the actual release version.
(
    cd $tdir
    tar --delete -f p.tar "$pfx/version.h" || true
    mkdir -p "$pfx"
    cat > "$pfx/version.h" <<END
/* version.h - beanstalkd version header */
/* This file was generated by pkg.sh */
#define VERSION "$vers"
END
    tar rf p.tar "$pfx/version.h"
)

gzip -9 < $tdir/p.tar > "$file"