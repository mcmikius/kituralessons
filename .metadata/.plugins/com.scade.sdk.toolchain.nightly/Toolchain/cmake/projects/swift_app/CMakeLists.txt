# CMake project for building scade swift application
project(SwiftScadeApplication)
cmake_minimum_required(VERSION 3.0)


set(SCADESDK_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../..")


# Include modules

list(APPEND CMAKE_MODULE_PATH "${SCADESDK_ROOT}/cmake/modules")


include(ScadeSDK)
include(CheckPathVariable)


check_path_variable(SCADESDK_USER_PATH "swift app sources")

if(NOT DEFINED SCADESDK_APP_NAME)
    message(FATAL_ERROR "Phoenix application name is not set. Please set SCADESDK_APP_NAME variable")
endif()

if(NOT DEFINED SCADESDK_PACKAGE_NAME)
    message(FATAL_ERROR "Application package name is not set. Please set SCADESDK_PACKAGE_NAME variable")
endif()


# collecting application sources and resources
file(GLOB_RECURSE app_files RELATIVE "${SCADESDK_USER_PATH}" "${SCADESDK_USER_PATH}/*")


# adding scade application
add_scade_application_base("${SCADESDK_APP_NAME}"
                           "${SCADESDK_PACKAGE_NAME}"
                           "${SCADESDK_USER_PATH}"
                           ${app_files})

