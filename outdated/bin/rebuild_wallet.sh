#!/usr/bin/bash
MOD="${1}"
set -e 

# START CUSTOMIZATION ZONE - for your system

#SOURCE_DIR="/storage/workspace/Employers/StashCrypto/rune/rune_wallet${MOD}"
#FELGO_ROOT="/opt/Felgo/Felgo"

# END CUSTOMIZATION ZONE

# load configuration realitive to this script
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
source "${SCRIPTPATH}/build"

PRJ=rune-wallet
SOURCE_DIR="${SOURCES_RUNE}/${PRJ}${MOD}"

if [[ ! -d "${SOURCE_DIR}" ]] ; then
        cd "${SOURCES_RUNE}"
	git clone git@github.com:digital-michael/${PRJ}.git ${PRJ}${MOD}
fi

cd "${SOURCE_DIR}"
rm -rf "${SOURCE_DIR}/build"
mkdir "${SOURCE_DIR}/build" 
cd "${SOURCE_DIR}/build"

"${FELGO_ROOT}/gcc_64/bin/qmake" -project .. 

${FELGO_ROOT}/gcc_64/bin/qmake \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/QtWidgets" \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/Felgo"  \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/QtQml" \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/QtQuickTest" \
LIBS+=-L"${FELGO_ROOT}/gcc_64/lib" \
LIBS+=-lQt5Widgets \
LIBS+=-lQt5Qml \
LIBS+=-lQt5Quick \
LIBS+=-lFelgo \
LIBS+=-lQt5WebSockets \
QMAKE_LFLAGS+=-lz \
CONFIG+=c++1z \
LIBS+=-lopentxs  


make -j`nproc`

echo Finished work in ${SOURCES_RUNE}
