
include(XcrunFindTool)


# Adds custom command for compiling assets for apple targets
function(add_compile_apple_assets outputs xcassets output_dir app_icon)
    # TODO: support detection of actool for multiple targets
    if(NOT DEFINED ACTOOL_PATH)
        xcrun_find_tool(actool_path "actool")
        set(ACTOOL_PATH "${actool_path}" CACHE STRING "Path to actool")
    endif()

    if(NOT "${app_icon}" STREQUAL "")
        set(app_icon_flags "--app-icon" "${app_icon}")
    else()
        set(app_icon_flags)
    endif()

    set(output "${output_dir}/Assets.car")
    add_custom_command(OUTPUT ${output}
                       COMMAND "${ACTOOL_PATH}"
                                "--output-format" "human-readable-text"
                                "--notices" "--warnings"
                                "--output-partial-info-plist" "pinfo_list"
                                ${app_icon_flags}
                                "--enable-on-demand-resources" "NO"
                                "--target-device" "mac"
                                "--minimum-deployment-target" "10.10"
                                "--platform" "macosx"
                                "--compile" "${output_dir}"
                                "${xcassets}"
                        DEPENDS "${xcassets}")

    set("${outputs}" "${output}" PARENT_SCOPE)
endfunction()
