
include(CopyAppResources)
include(AddCopyLibCommand)
include(AddPhoenixAppOptions)

set(PHOENIX_CONF_DIR "${CMAKE_CURRENT_LIST_DIR}/../config")


# Adds phoenix application for host platform (linux, osx, windows?)
function(add_phoenix_host_app target_name)

    cmake_parse_arguments(ADD_PHOENIX_HOST_APP "${ADD_PHOENIX_APP_ARGUMENTS_OPTIONS}"
                                               "${ADD_PHOENIX_APP_ARGUMENTS_ONE}"
                                               "${ADD_PHOENIX_APP_ARGUMENTS_MULTI}"
                                               ${ARGN})

    set(app_name "${ADD_PHOENIX_HOST_APP_APP_NAME}")
    if("${app_name}" STREQUAL "")
        set(app_name "${target_name}")
    endif()

    set(app_output_dir "${CMAKE_CURRENT_BINARY_DIR}/${app_name}.scadeapp")

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        list(APPEND ADD_PHOENIX_HOST_APP_RESOURCES
                    RESOURCES_GROUP "${PHOENIX_CONF_DIR}" "config" "log.conf")
    endif()

    # copy all resources to output directory
    copy_app_resources(scripts_deps
                       result_user_scripts
                       "${app_output_dir}"
                       ${ADD_PHOENIX_HOST_APP_RESOURCES})

    # copy all libraries to output directory
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        set(output_lib_dir "${app_output_dir}/Frameworks")
    else()
        set(output_lib_dir "${app_output_dir}/lib")
    endif()

    add_copy_libraries("${output_lib_dir}"
                       ADD_PHOENIX_HOST_APP_LIBRARIES
                       libs_deps
                       ADD_PHOENIX_HOST_APP_SEARCH_PATHS)

    add_custom_target(${target_name} ALL DEPENDS ${scripts_deps} ${libs_deps})
endfunction()

