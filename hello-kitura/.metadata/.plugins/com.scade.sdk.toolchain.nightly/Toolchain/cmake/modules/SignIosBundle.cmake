cmake_minimum_required(VERSION 3.0)

include(Plist)

set(PHOENIX_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")


# Adds commands for adding ad hoc signature to bundle
function(add_bundle_ios_ad_hoc_sign_target targ_name bundle_path)
    add_custom_target(${targ_name} ALL
                      COMMAND "/usr/bin/codesign" "--force"
                              "--sign" "-"
                              "--preserve-metadata=identifier,entitlements"
                              "${bundle_path}")
endfunction()


# Creates keychain from p12 cert for signing bundles. Stores certificate name into cert_name variable
function(create_ios_keychain cert_name_var keychain_path cert_path)
    if(NOT EXISTS "${keychain_path}")
        execute_process(COMMAND "security" "create-keychain" "-p" "mypass" "${keychain_path}"
                        RESULT_VARIABLE res
                        OUTPUT_VARIABLE output
                        ERROR_VARIABLE output)
        if("${res}" EQUAL "0")
            execute_process(COMMAND "security" "unlock-keychain" "-p" "mypass" "${keychain_path}"
                            RESULT_VARIABLE res
                            OUTPUT_VARIABLE output
                            ERROR_VARIABLE output)
            if("${res}" EQUAL "0")
                execute_process(COMMAND "security" "import" "${cert_path}" "-k" "${keychain_path}" "-P" "" "-T" "/usr/bin/codesign" "-A"
                                RESULT_VARIABLE res
                                OUTPUT_VARIABLE output
                                ERROR_VARIABLE output)
                if(NOT "${res}" EQUAL "0")
                    file(REMOVE "${keychain_path}")
                    message(FATAL_ERROR "Can't import cert into keychain: ${output}")
                endif()
            else()
                file(REMOVE "${keychain_path}")
                message(FATAL_ERROR "Can't unlock keychain: ${output}")
            endif()
        else()
            message(FATAL_ERROR "Can't create keychain: ${output}")
        endif()
    endif()

    # getting cert name
    execute_process(COMMAND "openssl" "pkcs12" "-in" "${cert_path}" "-nodes" "-passin" "pass:"
                    COMMAND "openssl" "x509" "-noout" "-subject"
                    COMMAND "sed" "-E" "-n" "s/.*CN=([^\\/]*).*/\\1/p"
                    RESULT_VARIABLE res
                    OUTPUT_VARIABLE output
                    ERROR_VARIABLE error)
    if(NOT "${res}" EQUAL "0")
        message("Can't get cert name: ${output} ${error}")
    endif()
    
    string(STRIP "${output}" cert_name)
    
    # escaping () in cert name
    set(cert_name_escaped "${cert_name}")
    string(REPLACE "(" "\\(" cert_name_escaped "${cert_name_escaped}")
    string(REPLACE ")" "\\)" cert_name_escaped "${cert_name_escaped}")

    # storing cert name into output variable
    set(${cert_name_var} "${cert_name_escaped}" PARENT_SCOPE)
endfunction()


# Adds commands for signing std library in bundle
function(add_bundle_ios_stdlib_sign_target targ_name stdlib_path cert)
    # creating keychain
    set(keychain_path "${CMAKE_CURRENT_BINARY_DIR}/${targ_name}.keychain")
    create_ios_keychain(cert_name "${keychain_path}" "${cert}")

    # adding command for signing bundle
    add_custom_target(${targ_name} ALL
                      COMMAND "security" "unlock-keychain" "-p" "mypass" "${keychain_path}"
                      COMMAND "/usr/bin/codesign" "--force"
                              "--sign" "${cert_name}" "--keychain" "${keychain_path}"
                              "${stdlib_path}"
                      DEPENDS "${keychain_path}")
endfunction()


# Adds commands for signing custom framework inside bundle
function(add_bundle_ios_sign_framework_target targ_name framework_path cert)
    # creating keychain
    set(keychain_path "${CMAKE_CURRENT_BINARY_DIR}/${targ_name}.keychain")
    create_ios_keychain(cert_name "${keychain_path}" "${cert}")

    # adding command for signing bundle
    add_custom_target(${targ_name} ALL
                      COMMAND "security" "unlock-keychain" "-p" "mypass" "${keychain_path}"
                      COMMAND "/usr/bin/codesign" "--force"
                              "--sign" "${cert_name}" "--keychain" "${keychain_path}"
                              "--preserve-metadata=identifier,entitlements"
                              "${framework_path}"
                      DEPENDS "${keychain_path}")
endfunction()


# Adds commands for signing bundle using specified p12 cert
function(add_bundle_ios_sign_target targ_name bundle_path cert)
    # creating keychain
    set(keychain_path "${CMAKE_CURRENT_BINARY_DIR}/${targ_name}.keychain")
    create_ios_keychain(cert_name "${keychain_path}" "${cert}")

    # adding command for signing bundle
    add_custom_target(${targ_name} ALL
                      COMMAND "security" "unlock-keychain" "-p" "mypass" "${keychain_path}"
                      COMMAND "/usr/bin/codesign" "--force"
                              "--sign" "${cert_name}" "--keychain" "${keychain_path}"
                              "--preserve-metadata=identifier,entitlements"
                              "${bundle_path}"
                      DEPENDS "${keychain_path}")
endfunction()


# Adds commands for signing application bundle using specified p12 cert and prov profile
function(add_app_bundle_ios_sign_target targ_name bundle_path app_name cert_path prov_path)
    # creating keychain
    set(keychain_path "${CMAKE_CURRENT_BINARY_DIR}/${targ_name}.keychain")
    create_ios_keychain(cert_name "${keychain_path}" "${cert_path}")

    # parsing provision profile and saving it to XML file

    set(parsed_prov_path "${CMAKE_CURRENT_BINARY_DIR}/${targ_name}-provision.xml")

    execute_process(COMMAND "security" "cms" "-D" "-i" "${prov_path}"
                    RESULT_VARIABLE res
                    OUTPUT_VARIABLE out
                    ERROR_VARIABLE err)
    if(NOT "${res}" EQUAL "0")
        message(FATAL_ERROR "Can't parse provision profile: ${out} ${err}")
    endif()

    file(WRITE "${parsed_prov_path}" "${out}")

    # Reading app identifier from parsed provision profile
    execute_process(COMMAND "/usr/libexec/PlistBuddy" "-c" "Print :Entitlements:application-identifier" "${parsed_prov_path}"
                    RESULT_VARIABLE res
                    OUTPUT_VARIABLE out
                    ERROR_VARIABLE err)
    if(NOT "${res}" EQUAL "0")
        message(FATAL_ERROR "Can't read app id from provision profile: ${out} ${error}")
    endif()

    string(STRIP "${out}" app_id)
    message(STATUS "Application ID for target ${targ_name}: ${app_id}")

    # Reading team id from parsed provision profile
    execute_process(COMMAND "/usr/libexec/PlistBuddy" "-c" "Print :Entitlements:com.apple.developer.team-identifier" "${parsed_prov_path}"
                    RESULT_VARIABLE res
                    OUTPUT_VARIABLE out
                    ERROR_VARIABLE err)
    if(NOT "${res}" EQUAL "0")
        message(FATAL_ERROR "Can't read team id from provision profile: ${out} ${error}")
    endif()

    string(STRIP "${out}" team_id)
    message(STATUS "Team ID for target ${targ_name}: ${team_id}")

    # Configuring .xcent file

    set(output_xcent_path "${bundle_path}/${app_name}.xcent")

    set(APP_ID "${app_id}")
    set(TEAM_ID "${team_id}")
    set(KEYCHAIN_AG "${app_id}")

    set(xcent_prop_names)
    set(xcent_prop_types)
    set(xcent_prop_vals)
    plist_configure("${PHOENIX_ROOT}/cmake/ios/ios-app.xcent"
                    "${output_xcent_path}"
                    ""
                    ${ARGN})

    # copy provision profile to bundle directory

    set(output_prov_path "${bundle_path}/embedded.mobileprovision")

    add_custom_command(OUTPUT "${output_prov_path}"
                       COMMAND "${CMAKE_COMMAND}" "-E" "copy" "${prov_path}" "${output_prov_path}"
                       DEPENDS "${prov_path}")


    # Adding command for signing app
    add_custom_target(${targ_name} ALL
                      COMMAND "/usr/bin/codesign" "--force" "--sign" "${cert_name}"
                              "--keychain" "${keychain_path}"
                              "--entitlements" "${output_xcent_path}" "${bundle_path}"
                      DEPENDS "${output_prov_path}" "${output_xcent_path}")
endfunction()

