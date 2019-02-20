
# Finds path to tool with specified name using xcrun command
function(xcrun_find_tool res_var name)
# looking for xcrun program
    if(NOT DEFINED XCRUN_PATH)
        message(STATUS "Looking for xcrun program...")

        find_program(xcrun_path "xcrun")
        if("${xcrun_path}" STREQUAL "xcrun_path-NOTFOUND")
            message(FATAL_ERROR "Can't find xcrun program")
        endif()

        set(XCRUN_PATH "${xcrun_path}" CACHE STRING "Path to xcrun tool")
        message(STATUS "xcrun found in '${XCRUN_PATH}'")
    endif()

    message(STATUS "Looking for '${name}' tool using xcrun...")

    execute_process(COMMAND "xcrun" "-f" "${name}"
                    RESULT_VARIABLE res
                    OUTPUT_VARIABLE res_output
                    ERROR_VARIABLE res_error
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE)
    if("${res}" EQUAL "0")
        message(STATUS "Found '${name}' in '${res_output}'")
        set("${res_var}" "${res_output}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Can't find '${name}' tool: ${res_error}")
    endif()
endfunction()
