
set(_context_abi_line "")
set(_context_arch_line "")
if (APPLE AND CMAKE_OSX_ARCHITECTURES)
    if (CMAKE_OSX_ARCHITECTURES MATCHES "x86")
        set(_context_abi_line "-DBOOST_CONTEXT_ABI:STRING=sysv")
    elseif (CMAKE_OSX_ARCHITECTURES MATCHES "arm")
        set (_context_abi_line "-DBOOST_CONTEXT_ABI:STRING=aapcs")
    endif ()
    set(_context_arch_line "-DBOOST_CONTEXT_ARCHITECTURE:STRING=${CMAKE_OSX_ARCHITECTURES}")
endif ()

#pwd && cp ${CMAKE_CURRENT_LIST_DIR}/project-config.jam ./ &&
set(_boost_libraries, "--with-system --with-filesystem --with-log --with-locale --with-regex --with-chrono --with-atomic --with-date_time --with-iostreams --with-nowide")
set(_boost_settings, "--with-toolset=emscripten toolset=emscripten --threading=single address-model=32  ")

ExternalProject_Add(Boost
    URL https://github.com/boostorg/boost/releases/download/boost-1.87.0/boost-1.87.0-cmake.zip
    URL_HASH SHA256=03530dec778bc1b85b070f0b077f3b01fd417133509bb19fe7c142e47777a87b
    INSTALL_DIR         ${${PROJECT_NAME}_DEP_INSTALL_PREFIX}
    DOWNLOAD_DIR        ${${PROJECT_NAME}_DEP_DOWNLOAD_DIR}/${projectname}
    
    BUILD_IN_SOURCE     true
    CONFIGURE_COMMAND  emconfigure ./bootstrap.sh  threading=single address-model=32 
    BUILD_COMMAND  env CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS_${_build_type_upper}} -pthread -pthreads -Wno-unused-private-field -m32"  emmake ./b2 cxxflags=-DPTHREADS cxxflags=-DBOOST_THREAD_POSIX cxxflags=-pthread cxxflags=-DTHREAD  link=static  toolset=emscripten threading=single address-model=32 thread system filesystem regex chrono log atomic nowide iostreams random --with-system --with-filesystem  --with-locale --with-regex --with-chrono --with-atomic --with-date_time --with-iostreams --with-thread --with-log
    PATCH_COMMAND  echo -e "using gcc : : g++ : root=/usr/local/ <compileflags>-m32 <linkflags>-m32 ;">tools/build/v2/user-config.jam && chmod +x  ./bootstrap.sh && chmod +x ./tools/build/src/engine/build.sh
    INSTALL_COMMAND env CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS_${_build_type_upper}} -pthread -pthreads -Wno-unused-private-field -m32"  emmake ./b2 cxxflags=-DPTHREADS cxxflags=-DBOOST_THREAD_POSIX cxxflags=-pthread cxxflags=-DTHREAD install link=static  toolset=emscripten threading=single address-model=32  --prefix=${${PROJECT_NAME}_DEP_INSTALL_PREFIX} system filesystem regex chrono iostreams random atomic nowide thread log --with-log --with-system --with-filesystem  --with-locale --with-regex --with-chrono --with-atomic --with-date_time --with-iostreams --with-thread
    CMAKE_ARGS
        -DBOOST_EXCLUDE_LIBRARIES:STRING=contract|fiber|numpy|stacktrace|wave|test
        -DBOOST_LOCALE_ENABLE_ICU:BOOL=OFF # do not link to libicu, breaks compatibility between distros
        -DBUILD_TESTING:BOOL=OFF
        "${_context_abi_line}"
        "${_context_arch_line}"
        -DCMAKE_INSTALL_PREFIX:STRING=${${PROJECT_NAME}_DEP_INSTALL_PREFIX}
        -DCMAKE_MODULE_PATH:STRING=${CMAKE_MODULE_PATH}
        -DCMAKE_PREFIX_PATH:STRING=${${PROJECT_NAME}_DEP_INSTALL_PREFIX}
        -DCMAKE_DEBUG_POSTFIX:STRING=${CMAKE_DEBUG_POSTFIX}
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
        -DCMAKE_CXX_FLAGS_${_build_type_upper}:STRING="${CMAKE_CXX_FLAGS_${_build_type_upper}} -pthread -pthreads -Wno-unused-private-field -Wno-missing-template-arg-list-after-template-kw"
        -DCMAKE_C_FLAGS_${_build_type_upper}:STRING="${CMAKE_C_FLAGS_${_build_type_upper}} -pthread -pthreads -Wno-unused-private-field -Wno-missing-template-arg-list-after-template-kw"
        -DCMAKE_TOOLCHAIN_FILE:STRING=${CMAKE_TOOLCHAIN_FILE}
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
)

set(DEP_Boost_DEPENDS ZLIB)
