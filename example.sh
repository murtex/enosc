#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"
TESTDIR="${SRCDIR}/test/"

CONFIG="test.conf"
INCLUDE="./"
OUTPUT="test.h5"
PLOTDIR="plot/"

cd ${TESTDIR}
#${BUILDDIR}/bin/integrate -c ${CONFIG} -o ${OUTPUT} -i ${INCLUDE}
matlab -nosplash -nodesktop -r "plot( ${OUTPUT}, ${PLOTDIR} ); exit();"

