#!/bin/sh

SRCDIR=`pwd`
BUILDDIR="${SRCDIR}/build/"
EXAMPLEDIR="${SRCDIR}/example/"

CONFIGFILE=example.conf
INCLUDEDIR=./
DATAFILE=example.h5
LOGFILE=example.log
PLOTDIR=plot/

cd ${EXAMPLEDIR}
${BUILDDIR}/bin/integrate -c ${CONFIGFILE} -o ${DATAFILE} -i ${INCLUDEDIR} 2>&1 | tee ${LOGFILE}
matlab -nosplash -nodesktop -r "example( '${DATAFILE}', '${PLOTDIR}' ); exit();"

