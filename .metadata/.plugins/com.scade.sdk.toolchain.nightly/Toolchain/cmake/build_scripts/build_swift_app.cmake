# CMake script for building Scade swift application
# Executes cmake, make

cmake_minimum_required(VERSION 3.0)

# parsing arguments and adding them to CMAKE_USER_OPTS
include("${CMAKE_CURRENT_LIST_DIR}/build_common.cmake")

set(build_dir "${CMAKE_CURRENT_BINARY_DIR}")

# add toolchain file to cmake options
list(APPEND CMAKE_USER_OPTS
     "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_LIST_DIR}/../../scadesdk.toolchain.cmake")

# Executing cmake for Scade project
execute_process(COMMAND "${CMAKE_COMMAND}"
                        "${CMAKE_CURRENT_LIST_DIR}/../projects/swift_app"
                        ${CMAKE_USER_OPTS}
                WORKING_DIRECTORY "${build_dir}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "cmake for Scade app failed")
endif()


# Executing make for Scade project
execute_process(COMMAND "make" "-j4"
                WORKING_DIRECTORY "${build_dir}"
                RESULT_VARIABLE res)
if(NOT res EQUAL 0)
    message(FATAL_ERROR "make for Scade app failed")
endif()

