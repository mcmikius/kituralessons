
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../android/modules")

include(AddAndroidApp)
include(AddPhoenixAppOptions)


if("${PHOENIX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "PHOENIX_TARGET variable is not set")
endif()


# Path to prebuilt libraries (use directory relative to script location because this code
# should be executed from scade/phoenix build dir
set(PHOENIX_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
set(PHOENIX_LIB_DIR "${PHOENIX_ROOT}/lib/${PHOENIX_TARGET}")
set(PHOENIX_CONF_DIR "${CMAKE_CURRENT_LIST_DIR}/../config")
set(SCADESDK_TEMPLATES_DIR "${PHOENIX_LIB_DIR}/templates")

# Path to phoenix android java sources
set(PHOENIX_ANDROID_JAVA_SOURCES_BASE "${PHOENIX_LIB_DIR}/java")

# List of phoenix android java sources
set(PHOENIX_ANDROID_JAVA_SOURCES
    com/scade/phoenix/CRunnable.java
    com/scade/phoenix/DisplayView.java
    com/scade/phoenix/ImagePicker.java
    com/scade/phoenix/MainActivity.java
    com/scade/phoenix/PhoenixAttributedString.java
    com/scade/phoenix/PhoenixApplication.java
    com/scade/phoenix/PhoenixView.java
    com/scade/phoenix/PhoenixBitmapView.java
    com/scade/phoenix/PhoenixFrameAnimator.java
    com/scade/phoenix/PhoenixAnimatorListener.java
    com/scade/phoenix/PhoenixMap.java
    com/scade/phoenix/PhoenixWebView.java
    com/scade/phoenix/PhoenixLocationService.java
    com/scade/phoenix/PhoenixMapAnnotation.java
    com/scade/phoenix/PhoenixMapOverlay.java
    com/scade/phoenix/PhoenixTileProvider.java
    com/scade/phoenix/PhoenixScrollView.java
    com/scade/phoenix/PhoenixPaint.java
    com/scade/phoenix/PhoenixTextInput.java
    com/scade/phoenix/PhoenixUtils.java
    com/scade/phoenix/RequestService.java
    com/scade/phoenix/PhoenixVideoCapture.java
    com/scade/phoenix/Response.java
   )


function(add_phoenix_android_app
         target_name        # name of target to add
         package_name       # name of android package
        )

    # parsing options
    cmake_parse_arguments(ADD_PHOENIX_ANDROID_APP "${ADD_PHOENIX_APP_ARGUMENTS_OPTIONS}"
                                                  "${ADD_PHOENIX_APP_ARGUMENTS_ONE}"
                                                  "${ADD_PHOENIX_APP_ARGUMENTS_MULTI}"
                                                  ${ARGN})

    # setting variables for application iconst
    set(ANDROID_APP_ICON_MDPI "${PHOENIX_APP_ICON_MDPI}")
    set(ANDROID_APP_ICON_HDPI "${PHOENIX_APP_ICON_HDPI}")
    set(ANDROID_APP_ICON_XHDPI "${PHOENIX_APP_ICON_XHDPI}")
    set(ANDROID_APP_ICON_XXHDPI "${PHOENIX_APP_ICON_XXHDPI}")

    set(prop_target_name "${ADD_PHOENIX_ANDROID_APP_PROPERTIES_TARGET_NAME}")
    if("${prop_target_name}" STREQUAL "")
        set(prop_target_name "${target_name}")
    endif()

    set(app_name "${ADD_PHOENIX_ANDROID_APP_APP_NAME}")
    if("${app_name}" STREQUAL "")
        set(app_name "${target_name}")
    endif()

    set(apk_name "${ADD_PHOENIX_ANDROID_APP_ANDROID_APK_NAME}")
    if("${apk_name}" STREQUAL "")
        set(apk_name "${target_name}")
    endif()

    set(resources ${ADD_PHOENIX_ANDROID_APP_RESOURCES})

    list(APPEND resources
                RESOURCES_GROUP "${PHOENIX_CONF_DIR}" NOPREFIX "log.conf")

    # TODO: try move templates build instructions to ScadeSDK
    file(GLOB_RECURSE templates RELATIVE "${SCADESDK_TEMPLATES_DIR}" "${SCADESDK_TEMPLATES_DIR}/*.xmi")
    list(APPEND resources
                RESOURCES_GROUP "${SCADESDK_TEMPLATES_DIR}" "templates" ${templates})

    set(libs_list "${ADD_PHOENIX_ANDROID_APP_LIBRARIES}")
    list(APPEND libs_list
         "${PHOENIX_LIB_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}c++_shared${CMAKE_SHARED_LIBRARY_SUFFIX}")

    set(extra_jars_list ${ADD_PHOENIX_ANDROID_APP_JARS})

    set(keystore_opts)
    if(NOT "${ADD_PHOENIX_ANDROID_APP_ANDROID_KEYSTORE_PROPERTIES_FILE}" STREQUAL "")
        set(keystore_opts KEYSTORE_PROPERTIES_FILE "${ADD_PHOENIX_ANDROID_APP_ANDROID_KEYSTORE_PROPERTIES_FILE}")
    endif()

    set(permissions_opts)
    if(NOT "${ADD_PHOENIX_ANDROID_APP_ANDROID_PERMISSIONS}" STREQUAL "")
        set(permissions_opts PERMISSIONS ${ADD_PHOENIX_ANDROID_APP_ANDROID_PERMISSIONS})
    endif()

    set(manifest_opts)
    if(NOT "${ADD_PHOENIX_ANDROID_APP_ANDROID_MANIFEST}" STREQUAL "")
        set(manifest_opts MANIFEST "${ADD_PHOENIX_ANDROID_APP_ANDROID_MANIFEST}")
    endif()

    set(version_name_opts)
    if(NOT "${ADD_PHOENIX_ANDROID_APP_ANDROID_VERSION_NAME}" STREQUAL "")
        set(version_name_opts VERSION_NAME "${ADD_PHOENIX_ANDROID_APP_ANDROID_VERSION_NAME}")
    endif()

    set(version_code_opts)
    if(NOT "${ADD_PHOENIX_ANDROID_APP_ANDROID_VERSION_CODE}" STREQUAL "")
        set(version_code_opts VERSION_CODE "${ADD_PHOENIX_ANDROID_APP_ANDROID_VERSION_CODE}")
    endif()

    add_android_app("${target_name}-apk"
                    "${package_name}"
                    "com.scade.phoenix.PhoenixApplication"
                    "com.scade.phoenix.MainActivity"
                    RESOURCES ${resources}
                    LIBRARIES ${libs_list}
                    JAVA_SOURCES_BASE "${PHOENIX_ANDROID_JAVA_SOURCES_BASE}"
                    JAVA_SOURCES ${PHOENIX_ANDROID_JAVA_SOURCES}
                    JARS ${extra_jars_list}
                    APK_NAME "${apk_name}"
                    PROPERTIES_TARGET_NAME "${prop_target_name}"
                    APP_NAME "${app_name}"
                    ${permissions_opts}
                    ${keystore_opts}
                    ${manifest_opts}
                    ${version_name_opts}
                    ${version_code_opts}
                    LINK_DIRECTORIES ${ADD_PHOENIX_ANDROID_APP_SEARCH_PATHS})
endfunction()

