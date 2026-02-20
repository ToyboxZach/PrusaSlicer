
set(_srcdir ${CMAKE_CURRENT_LIST_DIR}/gmp)
set(_dstdir ${${PROJECT_NAME}_DEP_INSTALL_PREFIX})

if (MSVC)
    set(_output  ${_dstdir}/include/gmp.h 
                 ${_dstdir}/lib/libgmp-10.lib 
                 ${_dstdir}/bin/libgmp-10.dll)

    add_custom_command(
        OUTPUT  ${_output}
        COMMAND ${CMAKE_COMMAND} -E copy ${_srcdir}/include/gmp.h ${_dstdir}/include/
        COMMAND ${CMAKE_COMMAND} -E copy ${_srcdir}/lib/win${DEPS_BITS}/libgmp-10.lib ${_dstdir}/lib/
        COMMAND ${CMAKE_COMMAND} -E copy ${_srcdir}/lib/win${DEPS_BITS}/libgmp-10.dll ${_dstdir}/bin/
    )
    
    add_custom_target(dep_GMP SOURCES ${_output})

else ()
    string(TOUPPER "${CMAKE_BUILD_TYPE}" _buildtype_upper)
    set(_gmp_ccflags "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${_buildtype_upper}} -fPIC -DPIC -Wall -Wmissing-prototypes -Wpointer-arith -pedantic -fomit-frame-pointer -fno-common -O3 -Oz -fno-rtti  -msimd128 -msse2")
    set(_gmp_build_tgt "${CMAKE_SYSTEM_PROCESSOR}")

    set(_cross_compile_arg "")
    if (APPLE)
        if (CMAKE_OSX_ARCHITECTURES)
            set(_gmp_build_tgt ${CMAKE_OSX_ARCHITECTURES})
            set(_gmp_ccflags "${_gmp_ccflags} -arch ${CMAKE_OSX_ARCHITECTURES} -DNO_ASM -O3 -Oz -fno-rtti -msimd128 -msse2")
        endif ()
        if (${_gmp_build_tgt} MATCHES "arm")
            set(_gmp_build_tgt aarch64)
        endif()

        if (CMAKE_OSX_ARCHITECTURES)
            set(_cross_compile_arg --host=${_gmp_build_tgt}-apple-darwin21)
        endif ()

        set(_gmp_ccflags "${_gmp_ccflags} -DNO_ASM  -mmacosx-version-min=${DEP_OSX_TARGET}")
        set(_gmp_build_tgt "--build=${_gmp_build_tgt}-apple-darwin")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm")
            set(_gmp_ccflags "${_gmp_ccflags} -march=armv7-a -DNO_ASM") # Works on RPi-4
            set(_gmp_build_tgt armv7)
        endif()
        set(_gmp_build_tgt "--build=${_gmp_build_tgt}-pc-linux-gnu")
    else ()
        set(_gmp_build_tgt "") # let it guess
    endif()

    if (CMAKE_CROSSCOMPILING)
        # TOOLCHAIN_PREFIX should be defined in the toolchain file
        set(_cross_compile_arg --host=${TOOLCHAIN_PREFIX})
    endif ()
    cmake_parse_arguments(P_ARGS "" "INSTALL_DIR;BUILD_COMMAND;INSTALL_COMMAND" "CMAKE_ARGS" ${ARGN})

    ExternalProject_Add(dep_GMP
        EXCLUDE_FROM_ALL ON
        URL https://gmplib.org/download/gmp/gmp-6.2.1.tar.bz2
        URL_HASH SHA256=eae9326beb4158c386e39a356818031bd28f3124cf915f8c5b1dc4c7a36b4d7c
        DOWNLOAD_DIR ${${PROJECT_NAME}_DEP_DOWNLOAD_DIR}/GMP
        BUILD_IN_SOURCE ON 
        PATCH_COMMAND   echo "#! /bin/sh" > tmp && echo "unset HOST_CC" >> tmp &&  cat ./configure >> tmp && mv tmp ./configure && chmod +x ./configure 
        CONFIGURE_COMMAND env "CFLAGS=${_gmp_ccflags}" "CXXFLAGS=${_gmp_ccflags}" CC_FOR_BUILD=gcc emconfigure ./configure --disable-cxx --host=none  --enable-fft=yes  --enable-alloca=malloc-notreentrant --enable-shared=no --enable-static=yes   "--prefix=${${PROJECT_NAME}_DEP_INSTALL_PREFIX}" ${_gmp_build_tgt}
        BUILD_COMMAND     MPN_PATH="generic" emmake make  -j6 
        INSTALL_COMMAND   emmake make  install 
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:STRING=${${PROJECT_NAME}_DEP_INSTALL_PREFIX}
            -DCMAKE_MODULE_PATH:STRING=${CMAKE_MODULE_PATH}
            -DCMAKE_PREFIX_PATH:STRING=${${PROJECT_NAME}_DEP_INSTALL_PREFIX}
            -DCMAKE_DEBUG_POSTFIX:STRING=${CMAKE_DEBUG_POSTFIX}
            -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
            -DCMAKE_CXX_FLAGS_${_build_type_upper}:STRING=${CMAKE_CXX_FLAGS_${_build_type_upper}}
            -DCMAKE_C_FLAGS_${_build_type_upper}:STRING=${CMAKE_C_FLAGS_${_build_type_upper}}
            -DCMAKE_TOOLCHAIN_FILE:STRING=${CMAKE_TOOLCHAIN_FILE}
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
            ${P_ARGS_CMAKE_ARGS}
    )
endif ()


# TODO need to copy headers to spot?