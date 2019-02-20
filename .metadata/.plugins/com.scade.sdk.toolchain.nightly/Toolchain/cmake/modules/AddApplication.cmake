include(CMakeParseArguments)
include(AddCompileAppleAssets)

function(add_osx_application name)
    cmake_parse_arguments(
            ARG
            ""
            "INFO_PLIST"
            "RESOURCES"
            ${ARGN}
    )

    add_executable(${name} ${ARG_UNPARSED_ARGUMENTS} ${ARG_RESOURCES})
    target_compile_options(PhoenixSimulator PRIVATE -fmodules)


    if(ARG_INFO_PLIST)
        set_property(TARGET ${name} PROPERTY MACOSX_BUNDLE_INFO_PLIST ${ARG_INFO_PLIST})
    endif ()

    set(compiled_resources)
    set(assets)
    foreach(src ${ARG_UNPARSED_ARGUMENTS})
        get_filename_component(src_ext "${src}" EXT)
        get_filename_component(src_name "${src}" NAME_WE)

        # Compile xib's
        if("${src_ext}" STREQUAL ".xib")            
            set(output_nib "${CMAKE_CURRENT_BINARY_DIR}/${src_name}.nib")
            add_custom_command(OUTPUT "${output_nib}"
                    COMMAND ibtool --errors --warnings --notices --compile
                    "${output_nib}"
                    "${src}"
                    DEPENDS "${src}")

            list(APPEND compiled_resources ${output_nib})
        elseif("${src_ext}" STREQUAL ".xcassets")
            list(APPEND assets ${src})                    
        endif()
    endforeach()

    #Compile assets
    if(assets)        
        add_compile_apple_assets(compiled_assets "${assets}" ${CMAKE_CURRENT_BINARY_DIR} "")
        list(APPEND compiled_resources ${compiled_assets})
    endif()

    # Setup resources
    add_custom_target(compile-resources
            DEPENDS ${compiled_resources}
    )

    add_dependencies(${name} compile-resources)
    target_sources(${name} PUBLIC ${compiled_resources})
    
    set_target_properties(${name} PROPERTIES
        #BUILD_WITH_INSTALL_RPATH TRUE
        #INSTALL_RPATH "@executable_path"                
        MACOSX_BUNDLE TRUE
        #MACOSX_FRAMEWORK_IDENTIFIER com.scade.ScadeSimulator
        RESOURCE "${ARG_RESOURCES};${compiled_resources}"
        )

    install(TARGETS ${name} BUNDLE DESTINATION ${PHOENIX_INSTALL_BIN_DIR})
endfunction()


function(add_ios_application name)
    #TODO: implement
endfunction()

function(add_android_application name)
    #TODO: implement
endfunction()

function(add_phoenix_application name)
    #TODO: implement
endfunction()


