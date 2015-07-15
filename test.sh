#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"

CONFIG="test/test.conf"
INCLUDE="test/"
OUTPUT="test/test.h5"

${BUILDDIR}/bin/integrate

