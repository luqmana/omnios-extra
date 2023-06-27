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

PROG=tcpdump
VER=4.99.3
PKG=ooce/network/tcpdump
SUMMARY="tcpdump - TCP packet analyzer"
DESC="tcpdump - a powerful command-line TCP packet analyzer"

set_arch 64
test_relver '>=' 151045 && set_clangver

BUILD_DEPENDS_IPS="
    system/library/pcap
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
