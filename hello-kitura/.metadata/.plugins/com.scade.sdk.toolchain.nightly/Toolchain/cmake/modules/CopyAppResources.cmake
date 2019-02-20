
include(AddCopyCommand)


# Copies applicatoin resource into destination directory
# taking into account library targets
function(copy_app_resource
         result_deps
         result_file_list
         base_dir
         output_dir
         prefix
         res)

    set(deps "${${result_deps}}")
    set(file_list "${${result_file_list}}")

    if(TARGET "${res}")
        # copy target output to scripts directory
        get_property(output_name TARGET "${res}" PROPERTY OUTPUT_NAME)
        if(NOT "${output_name}" STREQUAL "")
            set(output_name
                "${CMAKE_SHARED_LIBRARY_PREFIX}${output_name}${CMAKE_SHARED_LIBRARY_SUFFIX}")

            if(NOT "${prefix}" STREQUAL "NOPREFIX")
                set(output_name "${prefix}/${output_name}")
            endif()

            set(output "${output_dir}/${output_name}")

            # we pass target name "${res}" as DEPENDS parameter in
            # in add_custom_command. This causes cmake to add dependency
            # from the target and add file dependency from target output
            add_custom_command(OUTPUT "${output}"
                               COMMAND "${CMAKE_COMMAND}" "-E" "copy"
                                       "$<TARGET_FILE:${res}>" "${output}"
                               DEPENDS "$<TARGET_FILE:${res}>")
            list(APPEND deps "${output}")
            list(APPEND file_list "${output_name}")
        else()
            list(APPEND deps "${res}")
        endif()
    else()
        set(full_res_name "${res}")

        if(IS_ABSOLUTE "${res}")
            get_filename_component(full_res_name "${res}" NAME)
            set(input "${res}")
        else()
            # if script name is relative file name then use
            # path relative to base_dir
            if("${base_dir}" STREQUAL "NOBASE")
                set(input "${res}")
            else()
                set(input "${base_dir}/${res}")
            endif()

            # if base dir + resource name is relative then
            # use current source directory as base dir
            if(NOT IS_ABSOLUTE "${input}")
                set(input "${CMAKE_CURRENT_SOURCE_DIR}/${input}")
            endif()
        endif()

        if(NOT EXISTS "${input}")
            message(FATAL_ERROR "Resource '${input}' does not exist")
        endif()

        if("${prefix}" STREQUAL "NOPREFIX")
            set(full_res_name "${full_res_name}")
        else()
            set(full_res_name "${prefix}/${full_res_name}")
        endif()

        set(output "${output_dir}/${full_res_name}")

        if(NOT IS_DIRECTORY "${input}")
            list(APPEND file_list "${full_res_name}")
            add_copy_command("${input}" "${output}")
            list(APPEND deps "${output}")
        endif()
    endif()

    set(${result_deps} ${deps} PARENT_SCOPE)
    set(${result_file_list} ${file_list} PARENT_SCOPE)
endfunction()


# Copy application resources into destination directory
# taking into account library targets
function(copy_app_resources deps_var resource_list_var target_dir)
    set(cur_asset_base "NOBASE")
    set(cur_asset_prefix "NOPREFIX")
    set(next_read_base FALSE)
    set(next_read_prefix FALSE)

    set(deps ${${deps_var}})
    set(resource_list ${${resource_list_var}})

    foreach(res ${ARGN})
        if("${res}" STREQUAL "RESOURCES_GROUP")
            set(next_read_base TRUE)
        elseif("${next_read_base}")
            # reading assets base
            set(cur_asset_base "${res}")
            set(next_read_base FALSE)
            set(next_read_prefix TRUE)
        elseif("${next_read_prefix}")
            # reading assets dest prefix
            set(cur_asset_prefix "${res}")
            set(next_read_prefix FALSE)
        else()
            # copying asset
            copy_app_resource(deps
                              resource_list
                              "${cur_asset_base}"
                              "${target_dir}"
                              "${cur_asset_prefix}"
                              "${res}")
        endif()
    endforeach()

    set(${deps_var} ${deps} PARENT_SCOPE)
    set(${resource_list_var} ${resource_list} PARENT_SCOPE)
endfunction()

