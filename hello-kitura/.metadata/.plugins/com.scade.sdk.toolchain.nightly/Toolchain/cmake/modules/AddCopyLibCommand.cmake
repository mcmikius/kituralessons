
# Creates custom command for installing library to output path
function(add_copy_lib_command output_path lib_path output_list lib_search_paths)

    if(TARGET "${lib_path}")
        set(target "${lib_path}")

        get_property(lib_type TARGET "${target}" PROPERTY TYPE)
        if(NOT "${lib_type}" STREQUAL "SHARED_LIBRARY")
            return()
        endif()

        # generator expressions are not supported in OUTPUT parameter of custom commands
        # so we have to use timestamp files as workaround
        set(output "${output_path}/$<TARGET_FILE_NAME:${target}>")
        set(timestamp_output "${CMAKE_CURRENT_BINARY_DIR}/libs-timestamp/${target}")

        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/libs-timestamp")

        set(lib_path "$<TARGET_FILE:${lib_path}>")

        # copy library to obj and lib dir and strip it
        add_custom_command(OUTPUT "${timestamp_output}"
                           COMMAND "${CMAKE_COMMAND}" -E copy "${lib_path}" "${output}"
                           COMMAND "${CMAKE_COMMAND}" -E touch "${timestamp_output}"
                           DEPENDS "${lib_path}" "${target}")

        append_list_parent("${output_list}" "${timestamp_output}")

    else()

        if(NOT IS_ABSOLUTE "${lib_path}")
            set(real_lib_path)
            set(real_shared_lib_name "${CMAKE_SHARED_LIBRARY_PREFIX}${lib_path}${CMAKE_SHARED_LIBRARY_SUFFIX}")
            set(real_static_lib_name "${CMAKE_STATIC_LIBRARY_PREFIX}${lib_path}${CMAKE_STATIC_LIBRARY_SUFFIX}")

            foreach(p ${${lib_search_paths}})
                if(IS_ABSOLUTE "${p}")
                    set(real_sp "${p}")
                else()
                    set(real_sp "${CMAKE_CURRENT_SOURCE_DIR}/${p}")
                endif()

                if(EXISTS "${real_sp}/${real_shared_lib_name}")
                    set(real_lib_path "${real_sp}/${real_shared_lib_name}")
                    break()
                elseif(EXISTS "${real_sp}/${real_static_lib_name}")
                    # we don't need add static library to APK
                    return()
                endif()
            endforeach()

            if("${real_lib_path}" STREQUAL "")
                message(STATUS "Library ${lib_path} was not found in search paths and will not be copied into target")
                return()
            else()
                message(STATUS "Found library in search path: ${lib_path} -> ${real_lib_path}")
                set(lib_path "${real_lib_path}")
            endif()
        endif()

        get_filename_component(lib_name "${lib_path}" NAME)

        set(output "${output_path}/${lib_name}")

        # copy library to obj dir
        add_copy_command("${lib_path}" "${output}")

        append_list_parent("${output_list}" "${output}" "${libs_output}")
    endif()
endfunction()

function(add_copy_libraries output_path lib_list output_list lib_search_paths)
    set(outputs)

    foreach(lib ${${lib_list}})
        add_copy_lib_command("${output_path}" "${lib}" outputs ${lib_search_paths})
    endforeach()

    set(${output_list} ${outputs} PARENT_SCOPE)
endfunction()

