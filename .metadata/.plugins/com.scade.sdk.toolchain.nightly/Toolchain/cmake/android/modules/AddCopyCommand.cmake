
# Appends elements to a list in parent scope
macro(append_list_parent lst)
    set(new_list ${${lst}})
    list(APPEND new_list ${ARGN})
    set(${lst} ${new_list} PARENT_SCOPE)
endmacro()


# Makes command for copying file
function(add_copy_command input output)
    add_custom_command(OUTPUT "${output}"
                       COMMAND "${CMAKE_COMMAND}" "-E" "copy" "${input}" "${output}"
                       DEPENDS "${input}")

    # Adding output to dependency list if specified
    if(${ARGC} LESS 3)
        return()
    endif()

    append_list_parent("${ARGN}" "${output}")
endfunction()

