# If user did not specify the SDK root to use, then query xcodebuild for it.
if (NOT CMAKE_OSX_SYSROOT)
  execute_process(COMMAND xcodebuild -version -sdk macosx Path
          OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Using SDK: ${CMAKE_OSX_SYSROOT}")
endif()
if (NOT EXISTS ${CMAKE_OSX_SYSROOT})
  message(FATAL_ERROR "Invalid CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT} "
          "does not exist.")
endif()

# Specify minimum version of deployment target.
if (NOT DEFINED OSX_DEPLOYMENT_TARGET)
  set(OSX_DEPLOYMENT_TARGET "10.10"
          CACHE STRING "Minimal OSX version to build for." )
  message(STATUS "Using the default minimal OSX version (10.10) since OSX_DEPLOYMENT_TARGET not provided!")
endif()

set(CMAKE_OSX_ARCHITECTURES "x86_64")
set(CMAKE_OSX_DEPLOYMENT_TARGET "${OSX_DEPLOYMENT_TARGET}")
set(XCODE_OSX_PLATFORM_VERSION_FLAGS
      "-mmacos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")

set(CMAKE_ASM_FLAGS "${XCODE_OSX_PLATFORM_VERSION_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT} ${CMAKE_ASM_FLAGS}")