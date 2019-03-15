#!/usr/bin/bash
MOD="${1}"
# START CUSTOMIZATION ZONE - for your system

SOURCE_DIR="/storage/workspace/Employers/StashCrypto/rune/runewallet${MOD}"
FELGO_ROOT="/opt/Felgo/Felgo"

# END CUSTOMIZATION ZONE


cd "${SOURCE_DIR}"
rm -rf "${SOURCE_DIR}/build"
mkdir "${SOURCE_DIR}/build" 
cd "${SOURCE_DIR}/build"

"${FELGO_ROOT}/gcc_64/bin/qmake" -project .. 

/opt/Felgo/Felgo/gcc_64/bin/qmake \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/QtWidgets" \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/Felgo"  \
INCLUDEPATH+="${FELGO_ROOT}/gcc_64/include/QtQml" \
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

