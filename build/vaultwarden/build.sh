#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=vaultwarden
VER=1.30.1
PKG=ooce/application/vaultwarden
SUMMARY="Bitwarden compatible server"
DESC="Unofficial Bitwarden compatible server written in Rust, formerly known "
DESC+="as bitwarden_rs"

DANIGARCIA=$GITHUB/dani-garcia
WEBVAULTVER=2023.10.0
WEBVAULTSHA256=17758e5a37af2e1f847d76d3386551c519526884ee06912d9f78d97e61dd52a0

set_arch 64

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/env.template
WEBVAULTDIR=/var$BASEDIR/web-vault
EXECFILE=$PREFIX/bin/$PROG

BMI_EXPECTED=1
CARGO_ARGS="--features sqlite,mysql,postgresql"
BUILD_DEPENDS_IPS="
    ooce/developer/rust
    ooce/library/mariadb-${MARIASQLVER//./}
    ooce/library/postgresql-${PGSQLVER//./}
"
export RUSTFLAGS="
    -C link-arg=-R$PREFIX/mariadb-$MARIASQLVER/lib/amd64
    -C link-arg=-R$PREFIX/pgsql-$PGSQLVER/lib/amd64
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
"

SKIP_LICENCES=bitwarden

copy_sample_config() {
    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$DESTDIR/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd $MKDIR -p "$dest_confdir" || logerr "mkdir failed"
    logcmd $CP $TMPDIR/$BUILDDIR/.env.template $DESTDIR/$relative_conffile \
        || logerr "copying configs failed"
}

get_webvault() {
    local prog_repo=bw_web_builds
    local prog=web-vault
    local relative_webvaultdir=${WEBVAULTDIR#/}
    local dest_webvaultdir=$DESTDIR/${relative_webvaultdir%/*}

    # We need to clone the original bitwarden web pieces to incorporate the
    # licences into the final package.
    BUILDDIR= clone_github_source bitwarden \
        "$GITHUB/bitwarden/web" v$WEBVAULTVER

    note -n "Pulling v$WEBVAULTVER prebuilt $prog"

    set_mirror "$DANIGARCIA/$prog_repo/releases/download"
    set_checksum sha256 $WEBVAULTSHA256

    BUILDDIR=$prog \
        download_source "v$WEBVAULTVER" bw_web_v$WEBVAULTVER

    logmsg "-- copying $prog"
    logcmd $MKDIR -p $DESTDIR/$relative_webvaultdir || logerr "mkdir failed"
    logcmd $RSYNC -a --delete $TMPDIR/$prog/ $DESTDIR/$relative_webvaultdir/ \
        || logerr "copying $prog failed"

}

init
clone_github_source $PROG "$DANIGARCIA/$PROG" $VER
BUILDDIR+=/$PROG
patch_source
prep_build
build_rust $CARGO_ARGS
install_rust
strip_install
copy_sample_config
get_webvault
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
