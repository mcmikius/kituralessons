
include(AddPhoenixApp)
include(Swift)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
set(find_program_old "${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}")
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
    include(FindJava)
    include(UseJava)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${find_program_old}")
endif()

set(SCADESDK_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")


# detecting scadesdk target from cmake variables
if("${SCADESDK_TARGET}" STREQUAL "")
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        set(SCADESDK_TARGET "linux")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        set(SCADESDK_TARGET "android-${ANDROID_ABI}")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        if(IOS)
            if("${IOS_PLATFORM}" STREQUAL "OS")
                set(SCADESDK_TARGET "iphoneos")
            else()
                set(SCADESDK_TARGET "iphonsimulator")
            endif()
        else()
            set(SCADESDK_TARGET "macos")
        endif()
    else()
        message(FATAL_ERROR "Don't know how to detect scadesdk target for OS ${CMAKE_SYSTEM_NAME}")
    endif()
endif()

set(PHOENIX_TARGET "${SCADESDK_TARGET}")


set(SCADESDK_LIB_DIR "${SCADESDK_ROOT}/lib/${SCADESDK_TARGET}")
set(SCADESDK_INCLUDE_DIR "${SCADESDK_ROOT}/lib/${SCADESDK_TARGET}/include")


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


# Adds Scade application into build with specified user base directory
function(add_scade_application
         target_name
         package_name)

    # replacing empty parameters with "#<EMPTY>" strings
    set(replaced_argn)
    foreach(par IN LISTS ARGN)
        if("${par}" STREQUAL "")
            set(new_par "#<EMPTY>")
        else()
            set(new_par "${par}")
        endif()

        list(APPEND replaced_argn "${new_par}")
    endforeach()

    set(options)
    set(one_args SOURCES_BASE ANDROID_KEYSTORE_PROPERTIES_FILE ANDROID_MANIFEST
                 ANDROID_VERSION_NAME ANDROID_VERSION_CODE
                 MACOS_CERT MACOS_PROVISION_PROFILE MACOS_APP_ICON_2X MACOS_APP_ICON_3X
                 MACOS_IPAD_APP_ICON MACOS_IPAD_APP_ICON_2X MACOS_IPAD_PRO_APP_ICON_2X)
    set(multi_args SOURCES ANDROID_PERMISSIONS MACOS_PLIST_PROPERTIES
                   JAVA_SOURCES STD_LIBRARIES RESOURCES MACOS_XCENT_PROPERTIES
                   LIBRARIES LIBRARIES_ANDROID-X86 LIBRARIES_ANDROID-ARMEABI-V7A
                             LIBRARIES_ANDROID-X86_64
                             LIBRARIES_MACOS LIBRARIES_IPHONESIMULATOR LIBRARIES_IPHONEOS
                             LIBRARIES_LINUX
                   SEARCH_PATHS SEARCH_PATHS_ANDROID-X86 SEARCH_PATHS_ANDROID-ARMEABI-V7A
                                SEARCH_PATHS_ANDROID-X86_64
                                SEARCH_PATHS_MACOS SEARCH_PATHS_IPHONESIMULATOR SEARCH_PATHS_IPHONEOS
                                SEARCH_PATHS_LINUX)
    cmake_parse_arguments(ADD_SCADE_APPLICATION "${options}" "${one_args}" "${multi_args}" "${replaced_argn}")

    # default sources base is current source dir
    if("${ADD_SCADE_APPLICATION_SOURCES_BASE}" STREQUAL "")
        set(ADD_SCADE_APPLICATION_SOURCES_BASE "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # all unparsed arguments are sources
    list(APPEND ADD_SCADE_APPLICATION_SOURCES ${ADD_SCADE_APPLICATION_UNPARSED_ARGUMENTS})

    # collecting application sources and resources
    set(swift_sources)
    set(app_resources)
    foreach(src ${ADD_SCADE_APPLICATION_SOURCES})
        if(IS_ABSOLUTE "${src}")
            set(full_src_name "${src}")
        else()
            set(full_src_name "${ADD_SCADE_APPLICATION_SOURCES_BASE}/${src}")
        endif()

        if(NOT EXISTS "${full_src_name}")
            message(FATAL_ERROR "Source file '${full_src_name}' does not exist")
        endif()

        get_filename_ext(fext "${src}")
        if("${fext}" STREQUAL ".swift" OR "${fext}" STREQUAL ".page.swift")
            list(APPEND swift_sources "${src}")
        else()
            list(APPEND app_resources "${src}")
        endif()
    endforeach()


    set(swift_sources_full)
    foreach(src ${swift_sources})
        if(IS_ABSOLUTE "${src}")
            list(APPEND swift_sources_full "${src}")            
        else()
            list(APPEND swift_sources_full "${ADD_SCADE_APPLICATION_SOURCES_BASE}/${src}")            
        endif()        
    endforeach()

    set(swift_options)
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        list(APPEND swift_options
             SWIFT_FLAGS "-F" "${SCADESDK_LIB_DIR}" "-framework" "ScadeKit")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        # adding libs/android/include into list of include dirs for Android
        list(APPEND swift_options
             SWIFT_FLAGS "-I" "${CMAKE_CURRENT_SOURCE_DIR}/lib/android/include")
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        set(SWIFT_INCLUDE_DIRS "${SCADESDK_INCLUDE_DIR}")
    endif()

    set(libraries ${ADD_SCADE_APPLICATION_LIBRARIES})
    set(search_paths ${ADD_SCADE_APPLICATION_SEARCH_PATHS})

    string(TOUPPER "${SCADESDK_TARGET}" SCADESDK_TARGET_UPPER)
    list(APPEND libraries ${ADD_SCADE_APPLICATION_LIBRARIES_${SCADESDK_TARGET_UPPER}})
    list(APPEND search_paths ${ADD_SCADE_APPLICATION_SEARCH_PATHS_${SCADESDK_TARGET_UPPER}})

    # filtering ScadeKit.framework library
    set(orig_libraries ${libraries})
    set(libraries)
    foreach(lib ${orig_libraries})
        if(NOT "${lib}" STREQUAL "ScadeKit.framework")
            list(APPEND libraries "${lib}")
        endif()
    endforeach()

    if("${SCADESDK_TARGET}" STREQUAL "iphoneos" OR "${SCADESDK_TARGET}" STREQUAL "iphonesimulator")
        # build executable for IOS
        set(app_sources_dir "${SCADESDK_ROOT}/lib/${SCADESDK_TARGET}/src")
        set(app_sources ${swift_sources_full}
                        "${app_sources_dir}/AppDelegate.swift"
                        "${app_sources_dir}/ViewController.swift")
        swift_add_executable(${target_name}
                             MODULE_NAME "${target_name}"
                             SOURCES ${app_sources}
                             ${swift_options}
                             LIBRARIES ${libraries})
        set_property(TARGET ${target_name} PROPERTY MACOSX_BUNDLE TRUE)
        set_property(TARGET ${target_name} PROPERTY MACOSX_BUNDLE_BUNDLE_NAME "${target_name}")
        set_property(TARGET ${target_name} PROPERTY MACOSX_BUNDLE_GUI_IDENTIFIER "${package_name}")

        # put bundle into Payload subdirectory for IOS device
        if("${SCADESDK_TARGET}" STREQUAL "iphoneos")
            set_property(TARGET ${target_name} PROPERTY RUNTIME_OUTPUT_DIRECTORY
                         "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-ios-build/Payload")
        endif()
    else()
        # adding swift library
        swift_add_library(${target_name} SHARED
                          MODULE_NAME "${target_name}"
                          SOURCES ${swift_sources_full}
                          ${swift_options}
                          LIBRARIES ${libraries})

        # adding lib/android/<abi> directory into list of directories for Android
        if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
            target_link_libraries(${target_name} PRIVATE "-L${CMAKE_CURRENT_SOURCE_DIR}/lib/android/${ANDROID_ABI}")
        endif()
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        target_link_libraries(${target_name} PRIVATE "-F${SCADESDK_LIB_DIR}")

        if(IOS)
            set_property(TARGET ${target_name} PROPERTY BUILD_RPATH "@executable_path/Frameworks")
        else()
            set_property(TARGET ${target_name} PROPERTY BUILD_RPATH "${CMAKE_SWIFT_LIBRARY_PATH}" "@loader_path/Frameworks")
        endif()
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        target_link_libraries(${target_name} PRIVATE "-L${SCADESDK_LIB_DIR}" "-lScadeKit")
    endif()

    set_property(TARGET ${target_name} PROPERTY LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    set_property(TARGET ${target_name} PROPERTY OUTPUT_NAME "${target_name}")

    set(package_libs ${libraries})

    if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        list(APPEND package_libs "${SCADESDK_LIB_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}ScadeKit${CMAKE_SHARED_LIBRARY_SUFFIX}")
    endif()

    set(frameworks)
    if(IOS)
        list(APPEND frameworks "${SCADESDK_LIB_DIR}/ScadeKit.framework")
    endif()

    # add swift runtime libraries to application package for Linux/Android/IOS
    # we need also move all swift libraries into SwiftSupport for IOS. We do it
    # via the RESOURCES option
    set(ios_swift_support_resources)

    if(IOS)
        list(APPEND ios_swift_support_resources IPA_RESOURCES RESOURCES_GROUP "${CMAKE_SWIFT_LIBRARY_PATH}" "SwiftSupport/iphoneos")
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR
       "${CMAKE_SYSTEM_NAME}" STREQUAL "Android" OR
       IOS)

        foreach(lib ${CMAKE_SWIFT_LIBRARY_FILE_NAMES})
            list(APPEND package_libs "${CMAKE_SWIFT_LIBRARY_PATH}/${lib}")

            if(IOS)
                list(APPEND ios_swift_support_resources "${CMAKE_SWIFT_LIBRARY_PATH}/${lib}")
            endif()
        endforeach()

        foreach(lib ${ADD_SCADE_APPLICATION_STD_LIBRARIES})
            set(lib_file "${CMAKE_SWIFT_LIBRARY_PATH}/${CMAKE_SHARED_LIBRARY_PREFIX}${lib}${CMAKE_SHARED_LIBRARY_SUFFIX}")
            if(NOT EXISTS "${lib_file}")
                message(FATAL_ERROR "Can't find std library '${lib}'")
            endif()

            target_link_libraries(${target_name} PRIVATE "${lib}")
            list(APPEND package_libs "${lib_file}")
        endforeach()
    endif()

    # Adding all libraries from lib directory into package libs
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        file(GLOB_RECURSE syslibs "${CMAKE_CURRENT_SOURCE_DIR}/lib/android/${ANDROID_ABI}/*")
        list(APPEND package_libs ${syslibs})
    endif()

    set(extra_jars)
    foreach(jar ${CMAKE_SWIFT_JAR_FILE_NAMES})
        list(APPEND extra_jars "${CMAKE_SWIFT_LIBRARY_PATH}/${jar}")
    endforeach()

    if(NOT "${SCADESDK_TARGET}" STREQUAL "iphoneos" AND
       NOT "${SCADESDK_TARGET}" STREQUAL "iphonesimulator")
        list(APPEND app_resources ${target_name})
    endif()

    # setting variables for application iconst
    set(PHOENIX_APP_ICON_MDPI "${SCADESDK_APP_ICON_MDPI}")
    set(PHOENIX_APP_ICON_HDPI "${SCADESDK_APP_ICON_HDPI}")
    set(PHOENIX_APP_ICON_XHDPI "${SCADESDK_APP_ICON_XHDPI}")
    set(PHOENIX_APP_ICON_XXHDPI "${SCADESDK_APP_ICON_XXHDPI}")

    set(keystore_opts)
    if(NOT "${ADD_SCADE_APPLICATION_ANDROID_KEYSTORE_PROPERTIES_FILE}" STREQUAL "")
        set(keystore_opts ANDROID_KEYSTORE_PROPERTIES_FILE "${ADD_SCADE_APPLICATION_ANDROID_KEYSTORE_PROPERTIES_FILE}")
    endif()

    set(permissions_opts)
    if(NOT "${ADD_SCADE_APPLICATION_ANDROID_PERMISSIONS}" STREQUAL "")
        set(permissions_opts ANDROID_PERMISSIONS ${ADD_SCADE_APPLICATION_ANDROID_PERMISSIONS})
    endif()

    set(manifest_opts)
    if(NOT "${ADD_SCADE_APPLICATION_ANDROID_MANIFEST}" STREQUAL "")
        set(manifest_opts ANDROID_MANIFEST "${ADD_SCADE_APPLICATION_ANDROID_MANIFEST}")
    endif()

    set(android_version_name_opts)
    if(NOT "${ADD_SCADE_APPLICATION_ANDROID_VERSION_NAME}" STREQUAL "")
        set(android_version_name_opts ANDROID_VERSION_NAME "${ADD_SCADE_APPLICATION_ANDROID_VERSION_NAME}")
    endif()

    set(android_version_code_opts)
    if(NOT "${ADD_SCADE_APPLICATION_ANDROID_VERSION_CODE}" STREQUAL "")
        set(android_version_code_opts ANDROID_VERSION_CODE "${ADD_SCADE_APPLICATION_ANDROID_VERSION_CODE}")
    endif()

    set(macos_cert_opts)
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_CERT}" STREQUAL "")
        list(APPEND macos_cert_opts MACOS_CERT "${ADD_SCADE_APPLICATION_MACOS_CERT}")
    endif()

    set(macos_prov_opts)
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_PROVISION_PROFILE}" STREQUAL "")
        list(APPEND macos_prov_opts MACOS_PROVISION_PROFILE "${ADD_SCADE_APPLICATION_MACOS_PROVISION_PROFILE}")
    endif()

    set(macos_icon_opts)
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_APP_ICON_2X}" STREQUAL "")
        list(APPEND macos_icon_opts MACOS_APP_ICON_2X "${ADD_SCADE_APPLICATION_MACOS_APP_ICON_2X}")
    endif()
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_APP_ICON_3X}" STREQUAL "")
        list(APPEND macos_icon_opts MACOS_APP_ICON_3X "${ADD_SCADE_APPLICATION_MACOS_APP_ICON_3X}")
    endif()
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_IPAD_APP_ICON}" STREQUAL "")
        list(APPEND macos_icon_opts MACOS_IPAD_APP_ICON "${ADD_SCADE_APPLICATION_MACOS_IPAD_APP_ICON}")
    endif()
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_IPAD_APP_ICON_2X}" STREQUAL "")
        list(APPEND macos_icon_opts MACOS_IPAD_APP_ICON_2X "${ADD_SCADE_APPLICATION_MACOS_IPAD_APP_ICON_2X}")
    endif()
    if(NOT "${ADD_SCADE_APPLICATION_MACOS_IPAD_PRO_APP_ICON_2X}" STREQUAL "")
        list(APPEND macos_icon_opts MACOS_IPAD_PRO_APP_ICON_2X "${ADD_SCADE_APPLICATION_MACOS_IPAD_PRO_APP_ICON_2X}")
    endif()

    # building additional java sources
    set(additional_jars)
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android" AND NOT "${ADD_SCADE_APPLICATION_JAVA_SOURCES}" STREQUAL "")
        set(android_jar_path "${ANDROID_SDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/android.jar")
        set(CMAKE_JAVA_COMPILE_FLAGS -source 1.7 -target 1.7)
        add_jar(AppJavaSources
                SOURCES ${ADD_SCADE_APPLICATION_JAVA_SOURCES}
                INCLUDE_JARS "${android_jar_path}")
        set(additional_jars "${CMAKE_CURRENT_BINARY_DIR}/AppJavaSources.jar")
    endif()

    add_phoenix_app("${target_name}-app"
                    "${package_name}"
                    RESOURCES RESOURCES_GROUP "${ADD_SCADE_APPLICATION_SOURCES_BASE}"
                                              NOPREFIX ${app_resources}
                              ${ADD_SCADE_APPLICATION_RESOURCES}
                    LIBRARIES ${package_libs}
                    ${ios_swift_support_resources}
                    FRAMEWORKS ${frameworks}
                    JARS ${extra_jars} ${additional_jars}
                    PROPERTIES_TARGET_NAME "${target_name}"
                    APP_NAME "${target_name}"
                    ANDROID_APK_NAME "${target_name}"
                    ${permissions_opts}
                    ${keystore_opts}
                    ${manifest_opts}
                    ${android_version_name_opts}
                    ${android_version_code_opts}
                    SEARCH_PATHS ${search_paths}
                    ${macos_cert_opts}
                    ${macos_prov_opts}
                    ${macos_icon_opts}
                    MACOS_PLIST_PROPERTIES ${ADD_SCADE_APPLICATION_MACOS_PLIST_PROPERTIES}
                    MACOS_XCENT_PROPERTIES ${ADD_SCADE_APPLICATION_MACOS_XCENT_PROPERTIES})

    set_property(TARGET ${target_name} PROPERTY PHOENIX_APP_NAME "${target_name}")

    set(real_search_paths)

    foreach(dir ${search_paths})
        if(IS_ABSOLUTE "${dir}")
            set(real_dir "${dir}")
        else()
            set(real_dir "${CMAKE_CURRENT_SOURCE_DIR}/${dir}")
        endif()

        list(APPEND real_search_paths "${real_dir}")
    endforeach()

    foreach(dir ${real_search_paths})
        set_property(TARGET ${target_name} APPEND_STRING PROPERTY LINK_FLAGS " -L${dir}")
    endforeach()

    set_property(TARGET ${target_name} PROPERTY INCLUDE_DIRECTORIES "${real_search_paths}")
endfunction()


# Adds all SPM targets and links them with ScadeKit library
function(scade_add_spm)
    set(options)
    set(one_args)
    set(multi_args PACKAGES LIBRARIES SWIFT_FLAGS)
    cmake_parse_arguments(SCADE_ADD_SPM "${options}" "${one_args}" "${multi_args}" ${ARGN})

    set(swift_flags ${SCADE_ADD_SPM_SWIFT_FLAGS})
    set(libraries ${SCADE_ADD_SPM_LIBRARIES})

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        list(APPEND swift_flags "-F" "${SCADESDK_LIB_DIR}" "-framework" "ScadeKit")
        list(APPEND libraries "-F${SCADESDK_LIB_DIR}")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        list(APPEND swift_flags "-I" "${SCADESDK_INCLUDE_DIR}")
        list(APPEND libraries "-L${SCADESDK_LIB_DIR}" "-lScadeKit")
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        list(APPEND swift_flags "-I" "${CMAKE_CURRENT_SOURCE_DIR}/lib/android/include")
    endif()

    swift_add_spm(PACKAGES ${SCADE_ADD_SPM_PACKAGES}
                  LIBRARIES ${libraries}
                  SWIFT_FLAGS ${swift_flags})
endfunction()

