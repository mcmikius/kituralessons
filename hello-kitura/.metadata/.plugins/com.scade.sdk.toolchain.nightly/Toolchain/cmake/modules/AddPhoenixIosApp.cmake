
include(AddPhoenixAppOptions)
include(SignIosBundle)
include(Plist)


if("${PHOENIX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "PHOENIX_TARGET variable is not set")
endif()


# Path to prebuilt libraries (use directory relative to script location because this code
# should be executed from scade/phoenix build dir
set(PHOENIX_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
set(PHOENIX_LIB_DIR "${PHOENIX_ROOT}/lib/${PHOENIX_TARGET}")
set(PHOENIX_CONF_DIR "${CMAKE_CURRENT_LIST_DIR}/../config")
set(SCADESDK_TEMPLATES_DIR "${CMAKE_CURRENT_LIST_DIR}/../../templates")


function(add_phoenix_ios_app
         target_name        # name of target to add
         package_name
        )

    # parsing options
    cmake_parse_arguments(ADD_PHOENIX_IOS_APP "${ADD_PHOENIX_APP_ARGUMENTS_OPTIONS}"
                                              "${ADD_PHOENIX_APP_ARGUMENTS_ONE}"
                                              "${ADD_PHOENIX_APP_ARGUMENTS_MULTI}"
                                              ${ARGN})

    set(deps)

    set(prop_target_name "${ADD_PHOENIX_IOS_APP_PROPERTIES_TARGET_NAME}")
    if("${prop_target_name}" STREQUAL "")
        set(prop_target_name "${target_name}")
    endif()

    set(app_name "${ADD_PHOENIX_IOS_APP_APP_NAME}")
    if("${app_name}" STREQUAL "")
        set(app_name "${target_name}")
    endif()

    if("${IOS_PLATFORM}" STREQUAL "OS")
        set(payload_prefix "${CMAKE_CURRENT_BINARY_DIR}/${app_name}-ios-build")
        set(payload_dir "${payload_prefix}/Payload")
        set(build_dir "${payload_dir}/${app_name}.app")
    else()
        set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/${app_name}.app")
    endif()

    # copy application resources
    copy_app_resources(deps res_list "${build_dir}" ${ADD_PHOENIX_IOS_APP_RESOURCES})

    # copy additional libraries into IOS bundle
    # copy all libraries to output directory
    add_copy_libraries("${build_dir}/Frameworks"
                       ADD_PHOENIX_IOS_APP_LIBRARIES
                       output_libs
                       ADD_PHOENIX_IOS_APP_SEARCH_PATHS)

    list(APPEND deps ${output_libs})

    # copy IPA resources
    if("${IOS_PLATFORM}" STREQUAL "OS")
        copy_app_resources(deps res_list "${payload_prefix}" ${ADD_PHOENIX_IOS_APP_IPA_RESOURCES})
    endif()

    # copy additional frameworks into IOS bundle
    foreach(framework ${ADD_PHOENIX_IOS_APP_FRAMEWORKS})
        if(NOT EXISTS "${framework}")
            message(FATAL_ERROR "Framework '${framework}' not found")
        endif()

        get_filename_component(framework_name "${framework}" NAME)
        file(GLOB_RECURSE files RELATIVE "${framework}" "${framework}/*")

        # filtering headers and modules
        set(res_files)
        foreach(f ${files})
            if(NOT "${f}" MATCHES "^Headers" AND
               NOT "${f}" MATCHES "^Modules")
                list(APPEND res_files "${f}")
            endif()
        endforeach()

        copy_app_resources(deps tmp_list "${build_dir}/Frameworks/${framework_name}"
                           RESOURCES_GROUP "${framework}" NOPREFIX ${res_files})
    endforeach()

    # copy storyboard
    set(sb_dir "${PHOENIX_ROOT}/cmake/ios/Base.lproj")
    file(GLOB_RECURSE files RELATIVE "${sb_dir}" "${sb_dir}/*")
    copy_app_resources(deps tmp_list "${build_dir}"
                       RESOURCES_GROUP "${sb_dir}" "Base.lproj" ${files})

    # copy application icons
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_2X}" STREQUAL "")
        set(icon_path "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_2X}")
        if(NOT IS_ABSOLUTE "${icon_path}")
            set(icon_path "${CMAKE_CURRENT_SOURCE_DIR}/${icon_path}")
        endif()
        add_copy_command("${icon_path}" "${build_dir}/AppIcon@2x.png")
        list(APPEND deps "${build_dir}/AppIcon@2x.png")
    endif()
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_3X}" STREQUAL "")
        set(icon_path "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_3X}")
        if(NOT IS_ABSOLUTE "${icon_path}")
            set(icon_path "${CMAKE_CURRENT_SOURCE_DIR}/${icon_path}")
        endif()
        add_copy_command("${icon_path}" "${build_dir}/AppIcon@3x.png")
        list(APPEND deps "${build_dir}/AppIcon@3x.png")
    endif()
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON}" STREQUAL "")
        set(icon_path "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON}")
        if(NOT IS_ABSOLUTE "${icon_path}")
            set(icon_path "${CMAKE_CURRENT_SOURCE_DIR}/${icon_path}")
        endif()
        add_copy_command("${icon_path}" "${build_dir}/AppIcon~iPad.png")
        list(APPEND deps "${build_dir}/AppIcon~iPad.png")
    endif()
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON_2X}" STREQUAL "")
        set(icon_path "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON_2X}")
        if(NOT IS_ABSOLUTE "${icon_path}")
            set(icon_path "${CMAKE_CURRENT_SOURCE_DIR}/${icon_path}")
        endif()
        add_copy_command("${icon_path}" "${build_dir}/AppIcon~iPad@2x.png")
        list(APPEND deps "${build_dir}/AppIcon~iPad@2x.png")
    endif()
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_PRO_APP_ICON_2X}" STREQUAL "")
        set(icon_path "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_PRO_APP_ICON_2X}")
        if(NOT IS_ABSOLUTE "${icon_path}")
            set(icon_path "${CMAKE_CURRENT_SOURCE_DIR}/${icon_path}")
        endif()
        add_copy_command("${icon_path}" "${build_dir}/AppIcon~iPadPro@2x.png")
        list(APPEND deps "${build_dir}/AppIcon~iPadPro@2x.png")
    endif()

    # configuring Info.plist

    set(def_plist_props
        "BuildMachineOSBuild" STRING "15F34"
        "CFBundleDevelopmentRegion" STRING "en"
        "CFBundleExecutable" STRING "${app_name}"
        "CFBundleIdentifier" STRING "${package_name}"
        "CFBundleInfoDictionaryVersion" STRING "6.0"
        "CFBundleName" STRING "${app_name}"
        "CFBundlePackageType" STRING "APPL"
        "CFBundleShortVersionString" STRING "1.0"
        "CFBundleSignature" STRING "????"
        "CFBundleVersion" STRING "1"
        "DTCompiler" STRING "com.apple.compilers.llvm.clang.1_0"
        "DTPlatformBuild" STRING "13E230"
        "DTPlatformName" STRING "iphoneos"
        "DTPlatformVersion" STRING "9.3"
        "DTSDKBuild" STRING "13E230"
        "DTSDKName" STRING "iphoneos9.3"
        "DTXcode" STRING "0731"
        "DTXcodeBuild" STRING "7D1014"
        "LSRequiresIPhoneOS" BOOL TRUE
        "MinimumOSVersion" STRING "9.3"
        "UILaunchStoryboardName" STRING "LaunchScreen"
        "UIMainStoryboardFile" STRING "Main"
        "CFBundleSupportedPlatforms" ARRAY STRING "iPhoneOS" ARRAY_END
        "UIDeviceFamily" ARRAY INT 1 ARRAY_END
        "UIRequiredDeviceCapabilities" ARRAY STRING "arm64" ARRAY_END
        "UISupportedInterfaceOrientations" ARRAY
                                                STRING "UIInterfaceOrientationPortrait"
                                                STRING "UIInterfaceOrientationLandscapeLeft"
                                                STRING "UIInterfaceOrientationLandscapeRight"
                                           ARRAY_END
        "UISupportedInterfaceOrientations~ipad" ARRAY
                                                    STRING "UIInterfaceOrientationPortrait"
                                                    STRING "UIInterfaceOrientationPortraitUpsideDown"
                                                    STRING "UIInterfaceOrientationLandscapeLeft"
                                                    STRING "UIInterfaceOrientationLandscapeRight"
                                                ARRAY_END

       )

    set(plist_names_list)
    set(plist_types_list)
    set(plist_vals_list)

    set(plist_add_xml "")

    # adding application icons into plist if set in options
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_2X}" STREQUAL "" OR
       NOT "${ADD_PHOENIX_IOS_APP_MACOS_APP_ICON_3X}" STREQUAL "")
        set(plist_add_xml "${plist_add_xml}    <key>CFBundleIcons</key>\n")
        set(plist_add_xml "${plist_add_xml}    <dict>\n")
        set(plist_add_xml "${plist_add_xml}        <key>CFBundlePrimaryIcon</key>\n")
        set(plist_add_xml "${plist_add_xml}        <dict>\n")
        set(plist_add_xml "${plist_add_xml}            <key>CFBundleIconFiles</key>\n")
        set(plist_add_xml "${plist_add_xml}            <array>\n")
        set(plist_add_xml "${plist_add_xml}                <string>AppIcon</string>\n")
        set(plist_add_xml "${plist_add_xml}            </array>\n")
        set(plist_add_xml "${plist_add_xml}        </dict>\n")
        set(plist_add_xml "${plist_add_xml}    </dict>\n")
    endif()
    if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON}" STREQUAL "" OR
       NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON_2X}" STREQUAL "" OR
       NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_PRO_APP_ICON_2X}" STREQUAL "")
        set(plist_add_xml "${plist_add_xml}    <key>CFBundleIcons~ipad</key>\n")
        set(plist_add_xml "${plist_add_xml}    <dict>\n")
        set(plist_add_xml "${plist_add_xml}        <key>CFBundlePrimaryIcon</key>\n")
        set(plist_add_xml "${plist_add_xml}        <dict>\n")
        set(plist_add_xml "${plist_add_xml}            <key>CFBundleIconFiles</key>\n")
        set(plist_add_xml "${plist_add_xml}            <array>\n")

        if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON}" STREQUAL "" OR 
           NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_APP_ICON_2X}" STREQUAL "")
            set(plist_add_xml "${plist_add_xml}                <string>AppIcon~iPad</string>\n")
        endif()
        if(NOT "${ADD_PHOENIX_IOS_APP_MACOS_IPAD_PRO_APP_ICON_2X}" STREQUAL "")
            set(plist_add_xml "${plist_add_xml}                <string>AppIcon~iPadPro</string>\n")
        endif()

        set(plist_add_xml "${plist_add_xml}            </array>\n")
        set(plist_add_xml "${plist_add_xml}        </dict>\n")
        set(plist_add_xml "${plist_add_xml}    </dict>\n")
    endif()

    plist_merge(all_plist def_plist_props ADD_PHOENIX_IOS_APP_MACOS_PLIST_PROPERTIES)
    plist_configure("${PHOENIX_ROOT}/cmake/ios/Info.plist.cmake.in"
                    "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-Info.plist"
                    "${plist_add_xml}"
                    ${all_plist})

    # setting plist for bundle
    set_property(TARGET "${ADD_PHOENIX_IOS_APP_PROPERTIES_TARGET_NAME}"
                 PROPERTY MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${target_name}-Info.plist")

    add_custom_target(${target_name}-copy ALL DEPENDS ${deps})

    add_custom_target(${target_name} ALL)
    add_dependencies(${target_name} ${target_name}-copy)

    # signing and packing IOS application for IOS device
    if("${IOS_PLATFORM}" STREQUAL "OS")
        if("${ADD_PHOENIX_IOS_APP_MACOS_CERT}" STREQUAL "")
            message(FATAL_ERROR "Path to Apple certificate is not set")
        endif()

        if("${ADD_PHOENIX_IOS_APP_MACOS_PROVISION_PROFILE}" STREQUAL "")
            message(FATAL_ERROR "Path to Apple provision profile is not set")
        endif()

        # signing libraries

        add_custom_target(${target_name}-sign-libs)
        add_dependencies(${target_name} ${target_name}-sign-libs)

        foreach(lib ${output_libs})
            get_filename_component(lib_name "${lib}" NAME_WE)
            get_filename_component(lib_file_name "${lib}" NAME)
            add_bundle_ios_stdlib_sign_target(${target_name}-sign-lib-${lib_name} 
                                              "${build_dir}/Frameworks/${lib_file_name}"
                                              "${ADD_PHOENIX_IOS_APP_MACOS_CERT}")
            add_dependencies(${target_name}-sign-lib-${lib_name} ${target_name}-copy)
            add_dependencies(${target_name}-sign-libs ${target_name}-sign-lib-${lib_name})
        endforeach()

        # signing frameworks

        add_custom_target(${target_name}-sign-frameworks)
        add_dependencies(${target_name} ${target_name}-sign-frameworks)

        foreach(framework ${ADD_PHOENIX_IOS_APP_FRAMEWORKS})
            get_filename_component(framework_name "${framework}" NAME_WE)
            get_filename_component(framework_file_name "${framework}" NAME)
            add_bundle_ios_sign_framework_target(${target_name}-sign-framework-${framework_name} 
                                                 "${build_dir}/Frameworks/${framework_file_name}"
                                                 "${ADD_PHOENIX_IOS_APP_MACOS_CERT}")
            add_dependencies(${target_name}-sign-framework-${framework_name} ${target_name}-copy)
            add_dependencies(${target_name}-sign-frameworks ${target_name}-sign-framework-${framework_name})
        endforeach()

        # signing application
        add_app_bundle_ios_sign_target(${target_name}-sign-app
                                       "${build_dir}"
                                       "${app_name}"
                                       "${ADD_PHOENIX_IOS_APP_MACOS_CERT}"
                                       "${ADD_PHOENIX_IOS_APP_MACOS_PROVISION_PROFILE}"
                                       ${ADD_PHOENIX_IOS_APP_MACOS_XCENT_PROPERTIES})
        add_dependencies(${target_name}-sign-app
                         ${target_name}-sign-libs
                         ${target_name}-sign-frameworks
                         ${prop_target_name})

        # packing application
        add_custom_target(${target_name}-ipa ALL
                          COMMAND "zip" "-r" "../${app_name}.ipa" "*"
                          WORKING_DIRECTORY "${payload_prefix}")
        add_dependencies(${target_name}-ipa ${target_name}-sign-app)
    endif()
endfunction()

