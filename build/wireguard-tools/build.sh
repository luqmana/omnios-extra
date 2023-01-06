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

PROG=wireguard-tools
PKG=ooce/network/wireguard-tools
VER=1.0.20210914
HASH=8588ad1
SUMMARY="Tools for configuring WireGuard"
DESC="This supplies the main userspace tooling for using and configuring "
DESC+="WireGuard tunnels, including the wg(8) and wg-quick(8) utilities."

RUN_DEPENDS_IPS="ooce/network/wireguard-go"

XFORM_ARGS+="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DSERVICE=ooce/network/wg-quick
"

build_and_install() {
    pushd $TMPDIR/$BUILDDIR/$PROG/src
    logcmd $MAKE \
        SYSCONFDIR=/etc$PREFIX \
        PREFIX=$PREFIX \
        DESTDIR=$DESTDIR \
        WITH_WGQUICK=yes \
        install \
        || logerr "unable to build wireguard-tools"
    popd >/dev/null
}

init
prep_build
# Use nshalman fork until it is fully upstreamed
clone_github_source $PROG $GITHUB/nshalman/$PROG $HASH
build_and_install
xform files/wg-quick.xml > $TMPDIR/network-wg-quick.xml
install_smf ooce network-wg-quick.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
