
# Default ABI for scade is x86
if(NOT DEFINED ANDROID_ABI)
    set(ANDROID_ABI "x86")
endif()


# Default Android SDK
if(NOT DEFINED ANDROID_SDK)
    get_filename_component(android_studio_sdk "~/Android/Sdk" ABSOLUTE)
    if(EXISTS "${android_studio_sdk}")
        set(ANDROID_SDK "${android_studio_sdk}")
    else()
        if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
            set(os "macosx")
        elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
            set(os "linux")
        else()
            set(os "unknown")
        endif()

        set(ANDROID_SDK "/opt/android-sdk-${os}")
    endif()
endif()


# select clang toochain depending on ABI
if(NOT DEFINED ANDROID_TOOLCHAIN_NAME)
    if("${ANDROID_ABI}" MATCHES "arm64")
        set(ANDROID_TOOLCHAIN_NAME "aarch64-linux-android-clang3.8")
    elseif("${ANDROID_ABI}" MATCHES "arm")
        set(ANDROID_TOOLCHAIN_NAME "arm-linux-androideabi-clang3.8")
    elseif("${ANDROID_ABI}" MATCHES "x86_64")
        set(ANDROID_TOOLCHAIN_NAME "x86_64-clang3.8")
    elseif("${ANDROID_ABI}" MATCHES "x86")
        set(ANDROID_TOOLCHAIN_NAME "x86-clang3.8")
    else()
        message(FATAL_ERROR "Don't know how to select toolchain for '${ANDROID_ABI}' abi")
    endif()
endif()

set(ANDROID_STL c++_shared)

if(NOT DEFINED ANDROID_NATIVE_API_LEVEL)
    set(ANDROID_NATIVE_API_LEVEL 21)
endif()

set(TOOLCHAIN_VERSION 4.9)

include("${CMAKE_CURRENT_LIST_DIR}/android.toolchain.cmake")

