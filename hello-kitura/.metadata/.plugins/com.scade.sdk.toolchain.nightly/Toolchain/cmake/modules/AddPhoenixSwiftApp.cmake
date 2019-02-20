# Functions for building phoenix swift applications

cmake_minimum_required(VERSION 3.0)

include(CheckPathVariable)

# swift support

set(SWIFT_OBJC_INTEROP TRUE)

if(NOT CMAKE_SWIFT_PATH)
    message(FATAL_ERROR "Path to swfit compiler is not set, please set 
CMAKE_SWIFT_PATH variable")
endif()

include("${CMAKE_SWIFT_PATH}/lib/swift.cmake")


# Returs shortest extension of file
function(get_filename_ext var fname)
    get_filename_component(fext "${fname}" EXT)
    if("${fext}" STREQUAL "")
        # no extension
        set(${var} "" PARENT_SCOPE)
        return()
    endif()

    set(prev_fext "${fext}")

    while(TRUE)
        string(SUBSTRING "${prev_fext}" 1 -1 prev_fext_nodot)
        get_filename_component(fext "${prev_fext_nodot}" EXT)
        if("${fext}" STREQUAL "")
            set(${var} "${prev_fext}" PARENT_SCOPE)
            return()
        endif()

        set(prev_fext "${fext}")
    endwhile()
endfunction()


# Adds swift application into build
function(add_phoenix_swift_app name phoenix_path app_name output_dir app_sources_path)
    # creating output directory
    file(MAKE_DIRECTORY "${output_dir}")

    # collecting application sources and resources and trying detect app name
    set(swift_sources)
    set(app_resources)
    file(GLOB_RECURSE app_files RELATIVE "${app_sources_path}" "${app_sources_path}/*")
    foreach(f ${app_files})
        get_filename_ext(fext "${f}")
        if("${fext}" STREQUAL ".swift" OR "${fext}" STREQUAL ".page.swift")
            list(APPEND swift_sources "${f}")
        else()
            list(APPEND app_resources "${f}")
        endif()
    endforeach()

    message(STATUS "Swift application name: ${app_name}")

    # adding swift library

    set(swift_sources_full)
    set(SWIFT_INCLUDE_DIRS "${phoenix_path}/include")
    foreach(src ${swift_sources})
        list(APPEND swift_sources_full "${app_sources_path}/${src}")
    endforeach()

    swift_add_library(${name} "${app_name}" ${swift_sources_full})
    target_link_libraries(${name} PRIVATE "-L${phoenix_path}/lib" "-lscadesdk")
    set_property(TARGET ${name} PROPERTY LIBRARY_OUTPUT_DIRECTORY "${output_dir}")
    set_property(TARGET ${name} PROPERTY OUTPUT_NAME "${app_name}")

    # copying resources to output directory
    set(deps)
    foreach(res ${app_resources})
        set(input "${app_sources_path}/${res}")
        set(output "${output_dir}/${res}")
        add_custom_command(OUTPUT "${output}"
                           COMMAND "${CMAKE_COMMAND}" "-E" "copy" "${input}" "${output}"
                           DEPENDS "${input}")
        list(APPEND deps "${output}")
    endforeach()

    add_custom_target(swift-app-copy ALL DEPENDS ${deps})
    add_dependencies(${name} swift-app-copy)
endfunction()

