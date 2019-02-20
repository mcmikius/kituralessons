include(AddCopyCommand)
include(AddWriteListToFileCommand)
include(CopyAppResources)


# Path to android cmake scripts
set(ANDROID_SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}/../scripts")

# Path to android project template dir
set(ANDROID_PROJECT_TEMPLATE_DIR "${CMAKE_CURRENT_LIST_DIR}/../AndroidProjectTemplate")

# Path to additional android project files
set(ANDROID_PROJECT_FILES_DIR "${CMAKE_CURRENT_LIST_DIR}/../AndroidProjectFiles")


# Creates custom command for installing library into android project root
# The fourth optional argument is the name of list to add output
function(add_copy_android_lib_command root lib_path dep_list lib_search_paths)

    set(strip_command "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-strip")

    if(TARGET "${lib_path}")
        set(target "${lib_path}")

        get_property(lib_type TARGET "${target}" PROPERTY TYPE)
        if(NOT "${lib_type}" STREQUAL "SHARED_LIBRARY")
            return()
        endif()

        # generator expressions are not supported in OUTPUT parameter of custom commands
        # so we have to use timestamp files as workaround
        set(obj_output "${root}/obj/local/${ANDROID_ABI}/$<TARGET_FILE_NAME:${target}>")
        set(libs_output "${root}/libs/${ANDROID_ABI}/$<TARGET_FILE_NAME:${target}>")
        set(timestamp_output "${root}/libs-timestamp/${target}")

        file(MAKE_DIRECTORY "${root}/libs-timestamp")

        if(is_imported)
            set(lib_path "$<TARGET_PROERPTY:${lib_path},IMPORTED_LOCATION>")
        else()
            set(lib_path "$<TARGET_FILE:${lib_path}>")
        endif()

        # copy library to obj and lib dir and strip it
        add_custom_command(OUTPUT "${timestamp_output}"
                           COMMAND "${CMAKE_COMMAND}" -E copy "${lib_path}" "${obj_output}"
                           COMMAND "${CMAKE_COMMAND}" -E copy "${lib_path}" "${libs_output}"
                           COMMAND "${strip_command}" "${libs_output}"
                           COMMAND "${CMAKE_COMMAND}" -E touch "${timestamp_output}"
                           DEPENDS "${lib_path}" "${target}")

        append_list_parent("${dep_list}" "${timestamp_output}")

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
                message(STATUS "Library ${lib_path} was not found in search paths and will not be added into APK")
                return()
            else()
                message(STATUS "Found library in search path: ${lib_path} -> ${real_lib_path}")
                set(lib_path "${real_lib_path}")
            endif()
        endif()

        get_filename_component(lib_name "${lib_path}" NAME)

        set(obj_output "${root}/obj/local/${ANDROID_ABI}/${lib_name}")
        set(libs_output "${root}/libs/${ANDROID_ABI}/${lib_name}")

        # copy library to obj dir
        add_copy_command("${lib_path}" "${obj_output}")

        # copy library to libs dir and strip it
        add_custom_command(OUTPUT "${libs_output}"
                           COMMAND "${CMAKE_COMMAND}" -E copy "${lib_path}" "${libs_output}"
                           COMMAND "${strip_command}" "${libs_output}"
                           DEPENDS "${lib_path}")

        append_list_parent("${dep_list}" "${obj_output}" "${libs_output}")
    endif()
endfunction()


# Returns variable name containing path to app icon for specified DPI
function(get_app_icon_var_name res dpi)
    string(TOUPPER "${dpi}" dpi_upper)
    set(${res} "ANDROID_APP_ICON_${dpi_upper}" PARENT_SCOPE)
endfunction()


# Returns value of variable containing path to app icon fo specified DPI
function(get_app_icon res dpi)
    get_app_icon_var_name(var_name "${dpi}")
    set(${res} "${${var_name}}" PARENT_SCOPE)
endfunction()


# Creates custom commands for copying application icons to build directory
function(add_copy_app_icons_command project_dir build_dir dep_list)
    set(dpis "mdpi" "hdpi" "xhdpi" "xxhdpi")
    set(icons_deps)

    # determining if icon is set for any DPI and use it as default icon
    set(default_icon)
    foreach(dpi ${dpis})
        get_app_icon(icon "${dpi}")
        if(NOT "${icon}" STREQUAL "")
            set(default_icon "${icon}")
            break()
        endif()
    endforeach()

    # copy icons for each DPI
    foreach(dpi ${dpis})
        set(icon_file_path "res/drawable-${dpi}/ic_launcher.png")
        get_app_icon(icon "${dpi}")

        if(NOT "${icon}" STREQUAL "")
            set(icon_src "${icon}")
        else()
            # use default icon
            if(NOT "${default_icon}" STREQUAL "")
                set(icon_src "${default_icon}")
            else()
                set(icon_src "${project_dir}/${icon_file_path}")
            endif()
        endif()

        if(NOT IS_ABSOLUTE "${icon_src}")
            set(icon_src "${CMAKE_CURRENT_SOURCE_DIR}/${icon_src}")
        endif()

        add_copy_command("${icon_src}"
                         "${build_dir}/${icon_file_path}"
                         icons_deps)
    endforeach()

    append_list_parent(${dep_list} ${icons_deps})
endfunction()


# Adds android project to build
function(add_android_app
         target_name            # name of target to add
         package_name           # name of android package
         app_class_name         # name of application class
         activity_class_name    # name of activity class
        )

    # parsing options
    set(options COPY_STL)
    set(one_args JAVA_SOURCES_BASE KEYSTORE_PROPERTIES_FILE MANIFEST VERSION_NAME VERSION_CODE
                 APK_NAME PROPERTIES_TARGET_NAME APP_NAME)
    set(multi_args JAVA_SOURCES LIBRARIES JARS PERMISSIONS LINK_DIRECTORIES RESOURCES)
    cmake_parse_arguments(ADD_ANDROID_APP "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # setting APP name
    set(app_name "${ADD_ANDROID_APP_APP_NAME}")
    if("${app_name}" STREQUAL "")
        set(app_name "${target_name}")
    endif()

    # setting APK name
    set(apk_name "${ADD_ANDROID_APP_APK_NAME}")
    if("${apk_name}" STREQUAL "")
        set(apk_name "${target_name}")
    endif()

    # setting target name with properties
    set(prop_target_name "${ADD_ANDROID_APP_PROPERTIES_TARGET_NAME}")
    if("${prop_target_name}" STREQUAL "")
        set(prop_target_name "${target_name}")
    endif()


    set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-android")
    set(android_project_files_deps)

    set(output_assets_list)

    # copy android project template to build dir
    file(GLOB_RECURSE files
         RELATIVE "${ANDROID_PROJECT_TEMPLATE_DIR}" 
         "${ANDROID_PROJECT_TEMPLATE_DIR}/*")
    foreach(f ${files})
        add_copy_command("${ANDROID_PROJECT_TEMPLATE_DIR}/${f}"
                         "${build_dir}/${f}"
                         android_project_files_deps)
    endforeach()

    # building list of assets in project template
    file(GLOB_RECURSE assets_files
         LIST_DIRECTORIES false
         RELATIVE "${ANDROID_PROJECT_TEMPLATE_DIR}/assets"
         "${ANDROID_PROJECT_TEMPLATE_DIR}/assets/*")
    list(APPEND output_assets_list ${assets_files})

    # copy java sources
    foreach(src ${ADD_ANDROID_APP_JAVA_SOURCES})
        add_copy_command("${ADD_ANDROID_APP_JAVA_SOURCES_BASE}/${src}"
                         "${build_dir}/java_src/${src}"
                         android_project_files_deps)
    endforeach()

    # copy additional jars
    foreach(jar ${ADD_ANDROID_APP_JARS})
        get_filename_component(jar_name "${jar}" NAME)
        add_copy_command("${jar}"
                         "${build_dir}/libs/${jar_name}"
                         android_project_files_deps)
    endforeach()

    # copy resources to assets
    copy_app_resources(android_project_files_deps
                       output_assets_list
                       "${build_dir}/assets"
                       ${ADD_ANDROID_APP_RESOURCES})

    # copy application icons to build dir
    add_copy_app_icons_command("${ANDROID_PROJECT_FILES_DIR}" "${build_dir}" android_project_files_deps)

    foreach(lib ${ADD_ANDROID_APP_LIBRARIES})
        add_copy_android_lib_command("${build_dir}" "${lib}" android_project_files_deps ADD_ANDROID_APP_LINK_DIRECTORIES)
    endforeach()

    # copy STL shared to libs dir
    if(${ADD_ANDROID_APP_COPY_STL})
        # use thumb STL version if exists (thumb is ARM instruction mode)
        set(stl_path "${ANDROID_NDK}/sources/cxx-stl/llvm-libc++/libs/${ANDROID_NDK_ABI_NAME}")
        add_copy_android_lib_command("${build_dir}"
                                     "${stl_path}/${CMAKE_SHARED_LIBRARY_PREFIX}c++_shared${CMAKE_SHARED_LIBRARY_SUFFIX}"
                                     android_project_files_deps
                                     ADD_ANDROID_APP_LINK_DIRECTORIES)
    endif()


    # copy gdbserver to libs dir
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" OR "${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
        add_copy_command("${ANDROID_NDK}/prebuilt/android-${ANDROID_ARCH_NAME}/gdbserver/gdbserver"
                         "${build_dir}/libs/${ANDROID_ABI}/gdbserver"
                         android_project_files_deps)
    endif()


    add_custom_target(${target_name}-copy DEPENDS ${android_project_files_deps})

    # write path to android SDK to local.properties
    if("${ANDROID_SDK}" STREQUAL "")
        message(FATAL_ERROR "Path to android SDK is not set. Please set ANDROID_SDK variable")
    endif()
    configure_file("${ANDROID_PROJECT_FILES_DIR}/local.properties.cmake.in"
                   "${build_dir}/local.properties"
                   @ONLY)

    # write gdb.setup for ndk-gdb to build dir
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" OR "${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
        set(PROJECT_BUILD_DIR "${build_dir}")
        configure_file("${ANDROID_PROJECT_FILES_DIR}/gdb.setup.cmake.in"
                       "${build_dir}/libs/${ANDROID_ABI}/gdb.setup"
                       @ONLY)
    endif()

    # write dummy Android.mk for ndk-gdb to build dir
    configure_file("${ANDROID_PROJECT_FILES_DIR}/Android.mk.cmake.in"
                   "${build_dir}/jni/Android.mk"
                   @ONLY)

    # configuring android build files
    add_custom_command(OUTPUT "${build_dir}/AndroidManifest.xml"
                              "${build_dir}/build.gradle"
                       COMMAND "${CMAKE_COMMAND}"
                               "-DANDROID_APP_NAME=$<TARGET_PROPERTY:${prop_target_name},ANDROID_APP_NAME>"
                               "-DANDROID_PACKAGE_NAME=${package_name}"
                               "-DANDROID_APP_CLASS_NAME=${app_class_name}"
                               "-DANDROID_ACTIVITY_CLASS_NAME=${activity_class_name}"
                               "-DANDROID_API_KEY=${ANDROID_API_KEY}"
                               "-DANDROID_KEYSTORE_PROPERTIES_FILE=$<TARGET_PROPERTY:${prop_target_name},ANDROID_KEYSTORE_PROPERTIES_FILE>"
                               "-DPERMISSIONS=\"$<TARGET_PROPERTY:${prop_target_name},ANDROID_PERMISSIONS>\""
                               "-DMANIFEST=$<TARGET_PROPERTY:${prop_target_name},ANDROID_MANIFEST>"
                               "-DANDROID_VERSION_NAME=$<TARGET_PROPERTY:${prop_target_name},ANDROID_VERSION_NAME>"
                               "-DANDROID_VERSION_CODE=$<TARGET_PROPERTY:${prop_target_name},ANDROID_VERSION_CODE>"
                               "-P" "${ANDROID_SCRIPTS_DIR}/configure_android_build.cmake"
                       DEPENDS "${ANDROID_SCRIPTS_DIR}/configure_android_build.cmake"
                       WORKING_DIRECTORY "${build_dir}")
    add_custom_target(${target_name}-configure-build
                      DEPENDS "${build_dir}/AndroidManifest.xml"
                              "${build_dir}/build.gradle")

    # writing list of files in user folder to assets_list.txt
    set(scripts_list_file "${build_dir}/assets/assets_list.txt")
    add_write_list_to_file_command("${scripts_list_file}" "${output_assets_list}")
    add_custom_target(${target_name}-write-scripts-list DEPENDS "${scripts_list_file}")

    set(gradle_cmd "gradle")
    if(NOT "${ANDROID_GRADLE}" STREQUAL "")
        set(gradle_cmd "${ANDROID_GRADLE}")
    endif()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        set(gradle_subcommand "assembleDebug")
        set(apk_suffix "debug")
    else()
        set(gradle_subcommand "assembleRelease")
        set(apk_suffix "release")
    endif()

    add_custom_target(${target_name}-gradle ALL
                      COMMAND "${gradle_cmd}" "${gradle_subcommand}"
                      WORKING_DIRECTORY "${build_dir}")
    add_dependencies(${target_name}-gradle
                     ${target_name}-copy
                     ${target_name}-write-scripts-list
                     ${target_name}-configure-build)

    set(gradle_apk_name "${build_dir}/build/outputs/apk/${target_name}-android-${apk_suffix}.apk")
    set(result_apk_name "${CMAKE_CURRENT_BINARY_DIR}/${apk_name}-android-${ANDROID_ABI}.apk")
    add_custom_command(OUTPUT "${result_apk_name}"
                       COMMAND "${CMAKE_COMMAND}" "-E" "copy"
                               "${gradle_apk_name}" "${result_apk_name}"
                       DEPENDS "${target_name}-gradle" "${gradle_apk_name}")

    add_custom_target(${target_name} ALL DEPENDS "${result_apk_name}")


    # default versions
    
    if("${ADD_ANDROID_APP_VERSION_NAME}" STREQUAL "")
        set(ADD_ANDROID_APP_VERSION_NAME "1.0.0")
    endif()

    if("${ADD_ANDROID_APP_VERSION_CODE}" STREQUAL "")
        set(ADD_ANDROID_APP_VERSION_CODE "1")
    endif()


    # default properties for target
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_APP_NAME "${app_name}")
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_KEYSTORE_PROPERTIES_FILE "${ADD_ANDROID_APP_KEYSTORE_PROPERTIES_FILE}")
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_PERMISSIONS "${ADD_ANDROID_APP_PERMISSIONS}")
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_MANIFEST "${ADD_ANDROID_APP_MANIFEST}")
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_VERSION_NAME "${ADD_ANDROID_APP_VERSION_NAME}")
    set_property(TARGET ${prop_target_name} PROPERTY ANDROID_VERSION_CODE "${ADD_ANDROID_APP_VERSION_CODE}")
endfunction()

