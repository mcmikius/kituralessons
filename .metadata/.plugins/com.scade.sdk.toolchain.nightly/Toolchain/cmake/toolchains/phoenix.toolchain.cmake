if(PHOENIX_TOOLCHAIN_INCLUDED)
  return()
endif()
set(PHOENIX_TOOLCHAIN_INCLUDED true)

# if target is not set then use default target for host platform
if (NOT DEFINED PHOENIX_TARGET)
  if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
    set(PHOENIX_TARGET "linux")
  elseif ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    set(PHOENIX_TARGET "macos")
  else ()
    message(FATAL_ERROR "Unknown host system")
  endif ()
endif ()

if ("${PHOENIX_TARGET}" STREQUAL "macos")
  # can build osx target only on osx host
  if (NOT "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    message(FATAL_ERROR "Can build osx target only on osx host")
  endif ()

  include("${CMAKE_CURRENT_LIST_DIR}/osx.toolchain.cmake")

elseif ("${PHOENIX_TARGET}" STREQUAL "iphoneos" OR
        "${PHOENIX_TARGET}" STREQUAL "iphonesimulator")

  if (NOT "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    message(FATAL_ERROR "Can build osx target only on osx host")
  endif ()

  if ("${PHOENIX_TARGET}" STREQUAL "iphoneos")
    set(IOS_PLATFORM "OS")
  else ()
    set(IOS_PLATFORM "SIMULATOR64")
  endif ()

  if(NOT DEFINED IOS_DEPLOYMENT_TARGET)
    set(IOS_DEPLOYMENT_TARGET "9.3")
  endif()
  set(ENABLE_BITCODE FALSE)

  include("${CMAKE_CURRENT_LIST_DIR}/ios.toolchain.cmake")

elseif ("${PHOENIX_TARGET}" STREQUAL "linux")
  # can build linux target only on linux host
  if (NOT "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
    message(FATAL_ERROR "Can build linux target only on linux host")
  endif ()

  # use clang if not defined
  if (NOT DEFINED CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER "clang")
    set(CMAKE_CXX_COMPILER "clang++")
  endif ()

elseif ("${PHOENIX_TARGET}" STREQUAL "android-armeabi-v7a")
  set(ANDROID_ABI "armeabi-v7a")

  include("${CMAKE_CURRENT_LIST_DIR}/android.toolchain.scade.cmake")

elseif ("${PHOENIX_TARGET}" STREQUAL "android-x86")
  set(ANDROID_ABI "x86")

  include("${CMAKE_CURRENT_LIST_DIR}/android.toolchain.scade.cmake")

elseif ("${PHOENIX_TARGET}" STREQUAL "android-x86_64")
  set(ANDROID_ABI "x86_64")

  include("${CMAKE_CURRENT_LIST_DIR}/android.toolchain.scade.cmake")

else ()
  message(FATAL_ERROR "Unknown target: ${PHOENIX_TARGET}")
endif ()



# Setup processor architecture to be built for iOS and OSX
# On iOS we only build for the arm64 architecture
if(CMAKE_OSX_ARCHITECTURES MATCHES ".*arm.*")
  set(CMAKE_SYSTEM_PROCESSOR "arm64")
elseif(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64")
  set(CMAKE_SYSTEM_PROCESSOR "x86_64")
endif()
