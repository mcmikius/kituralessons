
# making list of cmake options
set(arg_num 1)
set(CMAKE_USER_OPTS)
while(arg_num LESS CMAKE_ARGC)
    set(arg "${CMAKE_ARGV${arg_num}}")
    if("${arg}" MATCHES "\\-D")
        list(APPEND CMAKE_USER_OPTS "${arg}")
    endif()

    math(EXPR arg_num "${arg_num} + 1")
endwhile()
