#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"

if [ ! -d ${BUILDDIR} ]; then
	mkdir -p ${BUILDDIR}
fi

cd ${BUILDDIR}
cmake ${SRCDIR}
make

