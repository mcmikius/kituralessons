
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/phoenix.toolchain.cmake")
    # This toolchain file is used in build stage dir.
    set(PHOENIX_SOURCES "${CMAKE_CURRENT_LIST_DIR}/../..")
else()
    # This toolchain file is used in source dir. Looking for Phoenix sources
    if(NOT DEFINED PHOENIX_SOURCES)
        set(PHOENIX_SOURCES "${CMAKE_CURRENT_LIST_DIR}/../../../Phoenix")
    endif()
    
    if(NOT EXISTS "${PHOENIX_SOURCES}" OR NOT IS_DIRECTORY "${PHOENIX_SOURCES}")
        message(FATAL_ERROR "Path to phoenix sources '${PHOENIX_SOURCES}' does not exist
or is not a directory. Please set correct path in PHOENIX_SOURCES variable")
    endif()
endif()

# Looking for Phoenix sources


if(DEFINED SCADESDK_TARGET)
    set(PHOENIX_TARGET "${SCADESDK_TARGET}")
endif()

include("${PHOENIX_SOURCES}/cmake/toolchains/phoenix.toolchain.cmake")

