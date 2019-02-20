
# Utitlity function for checking path variables

# Checks path variable
function(check_path_variable var desc)
    if(NOT DEFINED "${var}")
        message(FATAL_ERROR "${var} variable is not set. Please set correct path to ${desc}")
    endif()

    set(path "${${var}}")

    if(NOT EXISTS "${path}")
        message(FATAL_ERROR "Path '${path}' does not exist. Please set correct path to ${desc}")
    endif()

    if(NOT IS_DIRECTORY "${path}")
        message(FATAL_ERROR "Path '${path}' is not a directory. Please set correct path to ${desc}")
    endif()
endfunction()
