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

use --debug-find to figure out where its looking for libraries and then move dest dir to that spot

For boost make sure project-config.jam references gcc and not clang
if ! gcc in [ feature.values <toolset> ]
{
using gcc ;
}

In ./libs/unordered/include/boost/unordered/detail/fwd.hpp comment out
// #define BOOST_UNORDERED_HAVE_PIECEWISE_CONSTRUCT 1

I run

mkdir -p {Path to emsdk}/upstream/emscripten/cache/sysroot/{MY PATH TO PRUSA}/deps/build/destdir/usr/local/
cp -r {PATH TO PRUSA}/deps/build/destdir/usr/local/\* {Path to emsdk}/upstream/emscripten/cache/sysroot/{{MY PATH TO PRUSA}}/deps/build/destdir/usr/local/

Since emsdk being weird about dependencies
