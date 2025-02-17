
    set(_build_static ON)
set(CC emcc)
set(CXX em++)
set(EXTRA_CXX_OPTS "-Wimplicit-function-declaration")

add_cmake_project(Blosc
    URL https://github.com/Blosc/c-blosc/archive/8724c06e3da90f10986a253814af18ca081d8de0.zip
    URL_HASH SHA256=53986fd04210b3d94124b7967c857f9766353e576a69595a9393999e0712c035
    CMAKE_ARGS
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBUILD_SHARED=${_build_shared} 
        -DBUILD_STATIC=${_build_static}
        -DBUILD_TESTS=OFF 
        -DBUILD_BENCHMARKS=OFF 
       
        -DPREFER_EXTERNAL_ZLIB=ON
        -DCMAKE_CXX_FLAGS="-Wimplicit-function-declaration"
)

set(DEP_Blosc_DEPENDS ZLIB)
