cd deps
mkdir build
cd build
emcmake cmake .. 
emmake make
cd ../../
mkdir build
cd build

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


mkdir -p ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/
cp -r ${ABSOLUTE_PATH}/deps/dep_GMP-prefix/src/GMP/*.h  ${ABSOLUTE_PATH}/deps/build/destdir/usr/local/include/


cp .//Boost-prefix/src/Boost/bin.v2/libs/log/build/emscripten-4.0.1/release/address-model-32/link-static/target-os-none/visibility-hidden/libboost_log.a ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/lib/
cp -r ${ABSOLUTE_PATH}/deps/build/destdir/usr/local ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/
emcmake cmake .. -DCMAKE_PREFIX_PATH="$PWD/../deps/build/destdir/usr/local" -DSLIC3R_DESKTOP_INTEGRATION=OFF -DSLIC3R_GUI=OFF 
emmake make