#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"
EXAMPLEDIR="${SRCDIR}/example/"

CONFIG=example.conf
INCLUDE=./
DATAFILE=example.h5
PLOTDIR=plot/

cd ${EXAMPLEDIR}
#${BUILDDIR}/bin/integrate -c ${CONFIG} -o ${DATAFILE} -i ${INCLUDE}
matlab -nosplash -nodesktop -r "example( '${DATAFILE}', '${PLOTDIR}' ); exit();"

