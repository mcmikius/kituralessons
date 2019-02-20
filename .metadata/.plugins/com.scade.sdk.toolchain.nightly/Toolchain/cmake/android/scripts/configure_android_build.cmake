cmake_minimum_required(VERSION 3.0)

# Script for making android build files (manifest, build configs, etc)


set(ANDROID_CMAKE_INPUT_FILES "${CMAKE_CURRENT_LIST_DIR}/../AndroidProjectFiles")


if(NOT DEFINED ANDROID_APP_NAME)
    message(FATAL_ERROR "Android application name is not defined. Please set ANDROID_APP_NAME variable")
endif()

if(NOT DEFINED ANDROID_PACKAGE_NAME)
    message(FATAL_ERROR "Android package name is not defined. Please set ANDROID_PACKAGE_NAME variable")
endif()


# generating xml for android permissions
set(PERMISSIONS_XML)
foreach(perm ${PERMISSIONS})
    set(PERMISSIONS_XML "${PERMISSIONS_XML}    <uses-permission android:name=\"android.permission.${perm}\" />\n")
endforeach()


# configuring android manifest
if("${MANIFEST}" STREQUAL "")
    # use default manifest
    configure_file("${ANDROID_CMAKE_INPUT_FILES}/AndroidManifest.xml.cmake.in"
                   "AndroidManifest.xml"
                   @ONLY)
else()
    # use custom manifest
    configure_file("${MANIFEST}"
                   "AndroidManifest.xml"
                   @ONLY)
endif()

# configuring gradle build config
configure_file("${ANDROID_CMAKE_INPUT_FILES}/build.gradle.cmake.in"
               "build.gradle"
               @ONLY)


