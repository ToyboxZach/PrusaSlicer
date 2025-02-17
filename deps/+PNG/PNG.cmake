if (APPLE)
    # Only disable NEON extension for Apple ARM builds, leave it enabled for Raspberry PI.
    set(_disable_neon_extension "-DPNG_ARM_NEON:STRING=off")
else ()
    set(_disable_neon_extension "")
endif ()

set(_patch_cmd PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patched CMakeLists.txt)

if (APPLE)
    set(_patch_cmd ${_patch_cmd} && ${PATCH_CMD} ${CMAKE_CURRENT_LIST_DIR}/PNG.patch)
endif ()

set(ZLIB_INCLUDE_DIRS "/usr/local/opt/zlib/include")  
set(ZLIB_INCLUDE_DIR "/usr/local/opt/zlib/include")  
set(ZLIB_LIBRARY "/usr/local/opt/zlib/library")  

add_cmake_project(PNG 
URL https://github.com/glennrp/libpng/archive/refs/tags/v1.6.38.zip
URL_HASH SHA256=e1ab4aae9b88329d34bd1ca47adf3fb06c10153dbb660f4c80e2673f9fa94b24
    CMAKE_ARGS
        -DPNG_SHARED=OFF
        -DPNG_STATIC=ON
        #-DPNG_PREFIX=prusaslicer_
        -DPNG_TESTS=OFF
        -DZLIB_INCLUDE_DIR=/usr/local/opt/zlib/include
        -DZLIB_LIBRARY=/usr/local/opt/zlib/library
        -DZLIB_ROOT=/usr/local/opt/zlib/
        -DPNG_EXECUTABLES=OFF
        -DPNG_TOOLS=OFF
        ${_disable_neon_extension}
)

set(DEP_PNG_DEPENDS ZLIB)
