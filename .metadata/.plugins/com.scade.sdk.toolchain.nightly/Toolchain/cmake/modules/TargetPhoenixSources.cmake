include(CMakeParseArguments)

function(target_phoenix_sources TARGET)
    cmake_parse_arguments(SOURCES
            ""
            ""
            "OS;ARCH;PUBLIC;PRIVATE;INTERFACE"
            ${ARGN}
            )

    set(add_sources_to_target TRUE)

    if(SOURCES_OS AND PHOENIX_TARGET_OS)
        if(NOT PHOENIX_TARGET_OS IN_LIST SOURCES_OS)
            set(add_sources_to_target FALSE)
        endif()
    endif()

    if(SOURCES_ARCH AND PHOENIX_TARGET_ARCH)
        if(NOT PHOENIX_TARGET_ARCH IN_LIST SOURCES_ARCH)
            set(add_sources_to_target FALSE)
        endif()
    endif()

    if(add_sources_to_target)
        target_sources(${TARGET}
                PRIVATE ${SOURCES_PRIVATE}
                PUBLIC ${SOURCES_PUBLIC}
                INTERFACE ${SOURCES_INTERFACE}
                )
    endif()
endfunction()