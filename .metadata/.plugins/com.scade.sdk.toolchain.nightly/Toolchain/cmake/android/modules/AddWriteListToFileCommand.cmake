
set(ADD_WRITE_LIST_TO_FILE_COMMAND_SCRIPT_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Adds command for wirting list to file at build time
function(add_write_list_to_file_command file_name content)
    add_custom_command(OUTPUT "${file_name}"
                       COMMAND "${CMAKE_COMMAND}" "-DFILE_NAME=${file_name}"
                                                  "-DCONTENT=${content}"
                                                  "-P" "${ADD_WRITE_LIST_TO_FILE_COMMAND_SCRIPT_DIR}/../scripts/write_list_to_file.cmake" VERBATIM)
endfunction()

