

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
    include(AddPhoenixAndroidApp)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin" AND IOS)
    include(AddPhoenixIosApp)
endif()

include(AddPhoenixHostApp)


# Adds Phoenix project to build
function(add_phoenix_app
         target_name        # name of target to add
         package_name       # name of bundle package
        )

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        add_phoenix_android_app("${target_name}"
                                "${package_name}"
                                ${ARGN})

    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin" AND IOS)
        add_phoenix_ios_app("${target_name}" "${package_name}" ${ARGN})

    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR
           "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        add_phoenix_host_app("${target_name}" ${ARGN})

    else()
        message(FATAL_ERROR "Don't know how to build phoenix app for OS ${CMAKE_SYSTEM_NAME}")
    endif()
endfunction()

