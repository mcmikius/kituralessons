

# Writes plist value as XML
function(plist_write_value res prop_idx next_prop_idx_var_name)
    list(LENGTH ARGN prop_count)

    # reading property type from list
    if(NOT "${prop_idx}" LESS "${prop_count}")
        message(FATAL_ERROR "Missing property type in list of properties")
    endif()
    list(GET ARGN "${prop_idx}" prop_type)

    # reading property value from list
    math(EXPR prop_idx "${prop_idx} + 1")
    if(NOT "${prop_idx}" LESS "${prop_count}")
        message(FATAL_ERROR "Missing property value in list of properties")
    endif()
    list(GET ARGN "${prop_idx}" prop_val)

    if("${prop_type}" STREQUAL "STRING")
        if("${prop_val}" STREQUAL "#<EMPTY>")
            set(prop_val "")
        endif()

        set(xml_prop_val "<string>${prop_val}</string>")
    elseif("${prop_type}" STREQUAL "INT")
        set(xml_prop_val "<integer>${prop_val}</integer>")
    elseif("${prop_type}" STREQUAL "BOOL")
        if("${prop_val}" STREQUAL "TRUE" OR "${prop_val}" STREQUAL "YES")
            set(xml_prop_val "<true/>")
        elseif("${prop_val}" STREQUAL "FALSE" OR "${prop_val}" STREQUAL "NO")
            set(xml_prop_val "<false/>")
        else()
            message(FATAL_ERROR "Unknown PLIST BOOL property value '${prop_val}'")
        endif()
    elseif("${prop_type}" STREQUAL "ARRAY")
        set(xml_prop_val "<array>\n")

        while(NOT "${prop_val}" STREQUAL "ARRAY_END")
            plist_write_value(array_item_xml "${prop_idx}" next_idx ${ARGN})
            set(xml_prop_val "${xml_prop_val}    ${array_item_xml}\n")
            set(prop_idx "${next_idx}")
            list(GET ARGN "${prop_idx}" prop_val)
        endwhile()
        set(xml_prop_val "${xml_prop_val}</array>")
    else()
        message(FATAL_ERROR "Unknown PLIST property type '${prop_type}'")
    endif()

    math(EXPR prop_idx "${prop_idx} + 1")

    set("${res}" "${xml_prop_val}" PARENT_SCOPE)
    set("${next_prop_idx_var_name}" "${prop_idx}" PARENT_SCOPE)
endfunction()


# Writes lists of properties as plist XML
function(plist_write_properties res)
    set(res_xml)

    list(LENGTH ARGN prop_count)
    set(prop_idx 0)
    while("${prop_idx}" LESS "${prop_count}")
        # reading property name
        list(GET ARGN "${prop_idx}" prop_name)

        # writing property name to output XML
        set(res_xml "${res_xml}    <key>${prop_name}</key>\n")

        # writing property value to output XML
        math(EXPR prop_idx "${prop_idx} + 1")
        plist_write_value(val_xml "${prop_idx}" new_idx ${ARGN})

        set(res_xml "${res_xml}    ${val_xml}\n")
        set(prop_idx "${new_idx}")
    endwhile()

    set("${res}" "${res_xml}" PARENT_SCOPE)
endfunction()


# Reads property type and value from property definition list
function(read_property_type_and_value next_idx_var_name
                                      prop_type_var_name
                                      prop_value_var_name
                                      prop_idx)

    list(LENGTH ARGN list_size)

    # reading property type
    if(NOT "${prop_idx}" LESS "${list_size}")
        message(FATAL_ERROR "Missing property type in property list")
    endif()
    list(GET ARGN "${prop_idx}" prop_type)
    math(EXPR prop_idx "${prop_idx} + 1")

    # reading property value
    if(NOT "${prop_idx}" LESS "${list_size}")
        message(FATAL_ERROR "Missing property value in list of properties")
    endif()
    list(GET ARGN "${prop_idx}" prop_val)

    # reading all array values until ARRAY_END keyword
    if("${prop_type}" STREQUAL "ARRAY")
        set(array_item "${prop_val}")
        set(prop_val)

        while(NOT "${array_item}" STREQUAL "ARRAY_END")
            read_property_type_and_value(next_idx array_item_type array_item_value "${prop_idx}" ${ARGN})
            list(APPEND prop_val "${array_item_type}" "${array_item_value}")

            set(prop_idx "${next_idx}")
            if(NOT "${prop_idx}" LESS "${list_size}")
                message(FATAL_ERROR "Missing ARRAY_END keywork for array property type")
            endif()
            list(GET ARGN "${prop_idx}" array_item)
        endwhile()

        list(APPEND prop_val "ARRAY_END")
    endif()

    # increasing property index for next iteration
    math(EXPR prop_idx "${prop_idx} + 1")

    set("${next_idx_var_name}" "${prop_idx}" PARENT_SCOPE)
    set("${prop_type_var_name}" "${prop_type}" PARENT_SCOPE)
    set("${prop_value_var_name}" "${prop_val}" PARENT_SCOPE)
endfunction()


# Merges two plist propeties updating values for existing properties
function(plist_merge res list1_name list2_name)
    set(list1 ${${list1_name}})
    set(list2 ${${list2_name}})

    list(LENGTH list1 list1_length)
    list(LENGTH list2 list2_length)

    # collecting key names in list 2
    set(list2_idx "0")
    set(list2_names)
    while("${list2_idx}" LESS "${list2_length}")
        # reading property name
        list(GET list2 "${list2_idx}" prop_name)

        # reading property type and value
        math(EXPR list2_idx "${list2_idx} + 1")
        read_property_type_and_value(next_idx prop_type prop_val "${list2_idx}" ${list2})
        set(list2_idx "${next_idx}")

        list(APPEND list2_names "${prop_name}")
    endwhile()

    # copying all list1 values to result list filtering out values with names in list2
    set(res_list)
    set(list1_idx "0")
    while("${list1_idx}" LESS "${list1_length}")
        # reading property name
        list(GET list1 "${list1_idx}" prop_name)

        # reading property type and value
        math(EXPR list1_idx "${list1_idx} + 1")
        read_property_type_and_value(next_idx prop_type prop_val "${list1_idx}" ${list1})
        set(list1_idx "${next_idx}")

        # checking if list2 contains property with same name
        list(FIND list2_names "${prop_name}" idx)
        if("${idx}" EQUAL "-1")
            list(APPEND res_list "${prop_name}" "${prop_type}" "${prop_val}")
        endif()
    endwhile()

    # copying all list2 values to result list
    list(APPEND res_list "${list2}")

    set("${res}" ${res_list} PARENT_SCOPE)
endfunction()


# Configures plist templates and adds custom properties into it from specified list
function(plist_configure input output append_xml)
    plist_write_properties(PLIST_ADDITIONAL_PROPERTIES ${ARGN})
    set(PLIST_ADDITIONAL_PROPERTIES "${PLIST_ADDITIONAL_PROPERTIES}\n${append_xml}")
    configure_file("${input}" "${output}" @ONLY)
endfunction()

