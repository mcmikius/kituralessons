# CMake script for building ScadeSDK pacakge.
# Executes cmake, make, install, and zip

cmake_minimum_required(VERSION 3.0)

include("${CMAKE_CURRENT_LIST_DIR}/build_common.cmake")

set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/build")
set(install_dir "${CMAKE_CURRENT_BINARY_DIR}/scadesdk")


# checkign that output file name is specified
if(NOT DEFINED SCADESDK_OUTPUT_FILE)
    set(SCADESDK_OUTPUT_FILE "scadesdk.zip")
    message(STATUS "Use default output file name: ${SCADESDK_OUTPUT_FILE}")
endif()


# Creating build directory
file(MAKE_DIRECTORY "${build_dir}")


# Executing cmake for ScadeSDK project
execute_process(COMMAND "${CMAKE_COMMAND}"
                        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_LIST_DIR}/../../scadesdk.toolchain.cmake"
                        "${CMAKE_CURRENT_LIST_DIR}/../.."
                        "-DCMAKE_INSTALL_PREFIX=${install_dir}"
                        ${CMAKE_USER_OPTS}
                WORKING_DIRECTORY "${build_dir}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "cmake for ScadeSDK project failed")
endif()


# Executing make for ScadeSDK project
execute_process(COMMAND "make" "-j4"
                WORKING_DIRECTORY "${build_dir}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "make for ScadeSDK project failed")
endif()


# Executing make install for ScadeSDK project
execute_process(COMMAND "make" "install"
                WORKING_DIRECTORY "${build_dir}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "make intall for ScadeSDK project failed")
endif()


# Creating zip archive from install dir
execute_process(COMMAND "zip" "-r" "${SCADESDK_OUTPUT_FILE}" "scadesdk"
                WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "zip for ScadeSDK project failed")
endif()

