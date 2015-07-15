#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"
TESTDIR="${SRCDIR}/test/"

CONFIG="${TESTDIR}/test.conf"
INCLUDE="${TESTDIR}"
OUTPUT="${TESTDIR}/test.h5"

${BUILDDIR}/bin/integrate -c "${CONFIG}" -o "${OUTPUT}" -i "${INCLUDE}"

