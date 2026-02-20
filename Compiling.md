Here are my discoveries of things I had to mess around with to get it to compile.

I had to update boost, TBB and a few others
ANd make sure the deps are all linked with the right link flags

go into boost and run ./bootstrap.sh

./bootstrap.sh --with-libraries=system,date_time,filesystem,thread
./b2 toolset=emscripten link=static threading=multi cflags="-s USE_PTHREADS=1" cxxflags="-s USE_PTHREADS=1"

Might need to chmod +x on a couple things

On top of GMP cmake
unset HOST_CC in the configure

TBB
This change needs to be applied:
https://github.com/uxlfoundation/oneTBB/pull/550/files
and remove flags that it complains about

MPFR
Sometimes need to delete teh dep_MPFR_prefix and try agian if getting automake errors
Maybe need to set AUTOMAKE = true in MakeFile
Or in configure am\_\_api_version to your local automake version

emcmake cmake .. -DCMAKE_PREFIX_PATH="$PWD/../deps/build/destdir/usr/local" -DSLIC3R_DESKTOP_INTEGRATION=OFF -DSLIC3R_GUI=OFF

There is also a problem that at least on my machine emsdk has a seperate sys root and would not look outside of it no matter what I did, but some parts of CMake use the global location. I could not personally figure out how to make them look in the same place to be able to compile I just copied all my deps into the emsdk location.
I ran something like this:

You may have to symlink {Path to emsdk}/upstream/emscripten/cache/sysroot/{MY PATH TO PRUSA}/deps/build/destdir/usr/local/ with {PATH TO PRUSA}/deps/build/destdir/usr/local/
Some of the deps might themselves needs to look at that location, so you may need to do this also if some of the deps compilation fails.

Boost log had a problem being copied where it needed to be so I also directly copied that one.

Since emsdk being weird about dependencies

While building the full project I also had problems with a couple dirs being found
And had to set them explicitly if that is a problem,
This line might need to be adjusted:

set(Eigen3_DIR "${CMAKE_CURRENT_SOURCE_DIR}/deps/build/destdir/usr/local/share/eigen3/cmake")

This is a possible script that could work to build everyhing

```
cd deps
mkdir build
cd build
emcmake cmake ..
emmake make
cd ../../
mkdir build
cd build

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
so you
mkdir -p ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/
cp -r ${ABSOLUTE_PATH}/deps/dep_GMP-prefix/src/GMP/\*.h ${ABSOLUTE_PATH}/deps/build/destdir/usr/local/include/

cp .//Boost-prefix/src/Boost/bin.v2/libs/log/build/emscripten-4.0.1/release/address-model-32/link-static/target-os-none/visibility-hidden/libboost_log.a ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/lib/
cp -r ${ABSOLUTE_PATH}/deps/build/destdir/usr/local ${EMSDK_SYSROOT}/${ABSOLUTE_PATH}/deps/build/destdir/usr/local/
emcmake cmake .. -DCMAKE_PREFIX_PATH="$PWD/../deps/build/destdir/usr/local" -DSLIC3R_DESKTOP_INTEGRATION=OFF -DSLIC3R_GUI=OFF
emmake make
```

I have added a new compiling flag SMALL_WASM_BINARY

THis is to help reduce the size of the binary. The primary use is to remove support for the SLA printers which was ~9Mb
It also attempts to remove a few other things, and lower the number of defined strings.
