
#TODO need to apply patch  to fix build on mac
# https://github.com/uxlfoundation/oneTBB/pull/550/files
add_cmake_project(
    TBB
    URL "https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.13.0.zip"
    URL_HASH SHA256=f8dba2602f61804938d40c24d8f9b1f1cc093cd003b24901d5c3cc75f3dbb952
    PATCH_COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/Clang.cmake ./cmake/compilers/
    CMAKE_ARGS          
        -DTBB_BUILD_SHARED=OFF
        -DTBB_TEST=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DCMAKE_DEBUG_POSTFIX=_debug
        -DTBB_STRICT=OFF 
        -DTBB_DISABLE_HWLOC_AUTOMATIC_SEARCH=ON 
        -DBUILD_SHARED_LIBS=OFF 
        -DTBB_EXAMPLES=OFF 
        -DCMAKE_CXX_COMPILER=em++ 
        -DCMAKE_C_COMPILER=emcc
        -DTBB_STRICT=OFF
)


