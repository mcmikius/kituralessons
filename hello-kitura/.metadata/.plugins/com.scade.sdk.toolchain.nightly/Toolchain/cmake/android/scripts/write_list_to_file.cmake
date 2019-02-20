
if(NOT DEFINED FILE_NAME)
    message(FATAL_ERROR "File name is not set. Please set FILE_NAME variable")
endif()

file(WRITE "${FILE_NAME}" "")
foreach(item ${CONTENT})
    file(APPEND "${FILE_NAME}" "${item}\n")
endforeach()

