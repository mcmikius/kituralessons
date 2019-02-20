# Swift support for cmake

set(SWIFT_CMAKE_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

# detecting path to system swift compiler on OSX
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    # searching swift using xcrun tool
#    find_program(xcrun_tool "xcrun")
#    if("${xcrun_tool}" STREQUAL "xcrun_tool-NOTFOUND")
#        message(FATAL_ERROR "Can't find xcrun tool")
#    endif()

    # detecting path to swiftc compiler from xcode
    execute_process(COMMAND "xcrun" "-f" "swiftc"
                    RESULT_VARIABLE xcrun_res
                    OUTPUT_VARIABLE xcrun_out
                    ERROR_VARIABLE xcrun_error
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT "${xcrun_res}" EQUAL "0")
        message(FATAL_ERROR "xcrun can't find swiftc compiler: ${xcrun_out} ${xcrun_error}")
    endif()

    set(CMAKE_HOST_SWIFT_COMPILER "${xcrun_out}")
    message(STATUS "Found host swift compiler: ${CMAKE_HOST_SWIFT_COMPILER}")
    get_filename_component(tmp "${CMAKE_HOST_SWIFT_COMPILER}" "DIRECTORY")
    get_filename_component(CMAKE_HOST_SWIFT_PATH "${tmp}" "DIRECTORY")
endif()

# detecting path to swift
if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    if(NOT DEFINED CMAKE_SWIFT_PATH)
        message(FATAL_ERROR "Path to swift compiler is not set. Please set CMAKE_SWIFT_PATH variable")
    endif()

    find_program(CMAKE_SWIFT_COMPILER "swiftc"
                 "PATHS" "${CMAKE_SWIFT_PATH}/bin"
                 "NO_DEFAULT_PATH"
                 "NO_CMAKE_ENVIRONMENT_PATH"
                 "NO_CMAKE_PATH"
                 "NO_SYSTEM_ENVIRONMENT_PATH"
                 "NO_CMAKE_SYSTEM_PATH"
                 "NO_CMAKE_FIND_ROOT_PATH")

    if("${CMAKE_SWIFT_COMPILER}" STREQUAL "CMAKE_SWIFT_COMPILER-NOTFOUND")
        message(FATAL_ERROR "Can't find swift compiler in '${CMAKE_SWIFT_PATH}'")
    endif()

    set(SWIFT_USE_SYSTEM_COMPILER FALSE)
else()
    set(CMAKE_SWIFT_COMPILER "${CMAKE_HOST_SWIFT_COMPILER}")
    set(CMAKE_SWIFT_USE_SYSTEM_COMPILER TRUE)
endif()

message(STATUS "Found swift compiler: ${CMAKE_SWIFT_COMPILER}")
get_filename_component(tmp "${CMAKE_SWIFT_COMPILER}" "DIRECTORY")
get_filename_component(CMAKE_SWIFT_PATH "${tmp}" "DIRECTORY")


# setting swift target arch
if("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "amd64|x86_64")
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(CMAKE_SWIFT_TARGET_PROCESSOR "x86_64")
    else()
        set(CMAKE_SWIFT_TARGET_PROCESSOR "i686")
    endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86|i386|i586|i686")
    set(CMAKE_SWIFT_TARGET_PROCESSOR "i686")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "armv7")
    set(CMAKE_SWIFT_TARGET_PROCESSOR "armv7")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm64")
    set(CMAKE_SWIFT_TARGET_PROCESSOR "arm64")
else()
    message(FATAL_ERROR "Unknown swift target processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()


# setting swift target OS and ABI
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(CMAKE_SWIFT_TARGET_OS "linux")
    set(CMAKE_SWIFT_TARGET_TRIPLE_OS "unknown-linux")

    if("${CMAKE_SWIFT_TARGET_PROCESSOR}" STREQUAL "armv7")
        set(CMAKE_SWIFT_TARGET_TRIPLE_ABI "gnueabihf")
    else()
        set(CMAKE_SWIFT_TARGET_TRIPLE_ABI "gnu")
    endif()
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
    set(CMAKE_SWIFT_TARGET_OS "android")
    set(CMAKE_SWIFT_TARGET_TRIPLE_OS "unknown-linux")
    set(CMAKE_SWIFT_TARGET_TRIPLE_ABI "android")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    if(IOS)
      set(CMAKE_SWIFT_TARGET_OS "${XCODE_IOS_PLATFORM}")
      set(CMAKE_SWIFT_TARGET_TRIPLE_OS "apple")
      set(CMAKE_SWIFT_TARGET_TRIPLE_ABI "ios${IOS_DEPLOYMENT_TARGET}")
    else()
      set(CMAKE_SWIFT_TARGET_OS "macosx")
      set(CMAKE_SWIFT_TARGET_TRIPLE_OS "apple")
      set(CMAKE_SWIFT_TARGET_TRIPLE_ABI "macosx${OSX_DEPLOYMENT_TARGET}")
    endif()

else()
    message(FATAL_ERROR "Unknown swift target OS")
endif()

set(CMAKE_SWIFT_TARGET_TRIPLE
    "${CMAKE_SWIFT_TARGET_PROCESSOR}-${CMAKE_SWIFT_TARGET_TRIPLE_OS}-${CMAKE_SWIFT_TARGET_TRIPLE_ABI}")

# APINotes converter supports only apple target. APINotes target is used only for Availability
# module so we can use macosx target os for all targets
set(CMAKE_SWIFT_APINOTES_TRIPLE
    "${CMAKE_SWIFT_TARGET_PROCESSOR}-macosx-${CMAKE_SWIFT_TARGET_TRIPLE_ABI}")


if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" OR
   "${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    set(CMAKE_SWIFT_DEBUG_FLAGS "-g" "-DINTERNAL_CHECKS_ENABLED")
else()
    set(CMAKE_SWIFT_DEBUG_FLAGS)
endif()

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(CMAKE_SWIFT_OPT_FLAGS "-Onone")
else()
    set(CMAKE_SWIFT_OPT_FLAGS "-O")
endif()


# Path to swift libraries and includes

set(CMAKE_SWIFT_LIBRARY_PATH
    "${CMAKE_SWIFT_PATH}/lib/swift/${CMAKE_SWIFT_TARGET_OS}")

if(NOT CMAKE_SWIFT_USE_SYSTEM_COMPILER)
    set(CMAKE_SWIFT_LIBRARY_PATH "${CMAKE_SWIFT_LIBRARY_PATH}/${CMAKE_SWIFT_TARGET_PROCESSOR}")
endif()

set(CMAKE_SWIFT_LIBRARY_INCLUDE_PATH
    "${CMAKE_SWIFT_PATH}/lib/swift/${CMAKE_SWIFT_TARGET_OS}/include")


# Default options

if(NOT DEFINED SWIFT_OBJC_INTEROP)
    set(SWIFT_OBJC_INTEROP ON)
endif()

if(NOT DEFINED ENABLE_SWIFT_FOUNDATION)
    set(ENABLE_SWIFT_FOUNDATION ON)
endif()


# List of swift libraries
set(CMAKE_SWIFT_LIBRARY_NAMES
    "swiftCore"
    "swiftSwiftOnoneSupport"
    "swiftos")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES
         "swiftDarwin"
         "swiftContacts"
         "swiftCoreAudio"
         "swiftCoreGraphics"
         "swiftCoreFoundation"
         "swiftCoreImage"
         "swiftCoreMedia"
         "swiftDispatch"
         "swiftMetal"
         "swiftQuartzCore"
         "swiftUIKit")
else()
    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES
         "swiftGlibc"
         "scadeicu"
         "uuid"
         "xml2")
endif()

if(SWIFT_OBJC_INTEROP)
    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES
         "swiftFoundation"
         "swiftObjectiveC")

    if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        list(APPEND CMAKE_SWIFT_LIBRARY_NAMES 
             "Foundation"
             "objc")
    endif()
endif()

if(ENABLE_SWIFT_FOUNDATION AND NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    if(SWIFT_OBJC_INTEROP)
        set(swift_foundation_name "SwiftFoundation")
    else()
        set(swift_foundation_name "Foundation")
    endif()

    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES "swift${swift_foundation_name}")
    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES "dispatch")
endif()

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
    list(APPEND CMAKE_SWIFT_LIBRARY_NAMES "swiftJNI")
endif()

set(CMAKE_SWIFT_LIBRARY_FILE_NAMES)
foreach(lib ${CMAKE_SWIFT_LIBRARY_NAMES})
    list(APPEND CMAKE_SWIFT_LIBRARY_FILE_NAMES
         "${CMAKE_SHARED_LIBRARY_PREFIX}${lib}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endforeach()

set(CMAKE_SWIFT_JAR_FILE_NAMES)

if(ENABLE_SWIFT_FOUNDATION)
    list(APPEND CMAKE_SWIFT_JAR_FILE_NAMES "SwiftFoundation.jar")
endif()


# Adds target for compiling apinotes file for module
# Additional global variables
#   SWIFT_IMPORT_HEADERS - list of objc headers to import
function(swift_add_apinotes output source)
    add_custom_command(OUTPUT "${output}"
                       COMMAND "${CMAKE_SWIFT_COMPILER}" "-apinotes" "-yaml-to-binary" "-o" "${output}"
                               "-target" "${CMAKE_SWIFT_APINOTES_TRIPLE}"
                               "${source}"
                       DEPENDS "${source}")
endfunction()



# Adds command for building swift sources into object file
# Additional global variables
#   SWIFT_IMPORT_HEADERS - list of objc headers to import
function(swift_add_object)
    set(options NO_AUTOLINK)
    set(one_args OUTPUT MODULE_NAME MODULE_LINK_NAME MODULE_PATH TARGET_NAME TARGET_TYPE TARGET)
    set(multi_args SOURCES ADDITIONAL_OBJECTS SWIFT_FLAGS CFLAGS DEPENDS LIBRARIES)
    cmake_parse_arguments(SWIFT_ADD_OBJECT "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # adding all libraries into list of dependencies for swift object
    set(dependencies ${SWIFT_ADD_OBJECT_DEPENDS})
    foreach(lib ${SWIFT_ADD_OBJECT_LIBRARIES})
        if(TARGET "${lib}")
            list(APPEND dependencies "${lib}")
        endif()
    endforeach()

    if("${SWIFT_ADD_OBJECT_OUTPUT}" STREQUAL "")
        message(FATAL_ERROR "OUTPUT parameter is not specified of swift_add_object")
    endif()

    set(target_name "${SWIFT_ADD_OBJECT_TARGET_NAME}")

    set(target_type "${SWIFT_ADD_OBJECT_TARGET_TYPE}")
    if("${target_type}" STREQUAL "")
        message(FATAL_ERROR "TARGET_TYPE option must be passed to swift_add_object")
    endif()

    set(sources)
    foreach(src ${SWIFT_ADD_OBJECT_SOURCES})
        # checking for generator expressions for objects
        string(SUBSTRING "${src}" 0 2 start)
        if("${start}" STREQUAL "$<")
            continue()
        endif()

        # checking for relative paths
        if(NOT IS_ABSOLUTE "${src}")
            set(src "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        endif()

        list(APPEND sources "${src}")
    endforeach()

    get_filename_component(object_name "${SWIFT_ADD_OBJECT_OUTPUT}" NAME_WE)

    set(mcache_dir "${CMAKE_CURRENT_BINARY_DIR}/swift-object-${object_name}-mcache")
    file(MAKE_DIRECTORY "${mcache_dir}")

    if("${SWIFT_ADD_OBJECT_MODULE_NAME}" STREQUAL "")
        set(module_name_flags)
    else()
        set(module_name_flags "-emit-module" "-module-name" "${SWIFT_ADD_OBJECT_MODULE_NAME}")

        list(APPEND module_name_flags "-emit-module-path")
        if("${SWIFT_ADD_OBJECT_MODULE_PATH}" STREQUAL "")
            set(SWIFT_ADD_OBJECT_MODULE_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${SWIFT_ADD_OBJECT_MODULE_NAME}.swiftmodule")            
        else()
            get_filename_component(module_path_dir "${SWIFT_ADD_OBJECT_MODULE_PATH}" PATH)
            file(MAKE_DIRECTORY "${module_path_dir}")
            set(SWIFT_ADD_OBJECT_MODULE_OUTPUT "${SWIFT_ADD_OBJECT_MODULE_PATH}")            
        endif()
        list(APPEND module_name_flags ${SWIFT_ADD_OBJECT_MODULE_OUTPUT})
    endif()

    set(include_flags)
    foreach(dir ${SWIFT_INCLUDE_DIRS})
        list(APPEND include_flags "-I${dir}")
    endforeach()

    # android include dirs

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        list(APPEND include_flags
             "-I${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/arch-${ANDROID_ARCH_NAME}/usr/include")

        if(EXISTS "${ANDROID_NDK}/sysroot")
            list(APPEND include_flags
                 "-I${ANDROID_NDK}/sysroot/usr/include"
                 "-I${ANDROID_NDK}/sysroot/usr/include/${ANDROID_MULTIARCH_TRIPLE}")
        endif()
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        set(sdk_flags
            "-sdk" "${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/arch-${ANDROID_ARCH_NAME}")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        if("${CMAKE_OSX_SYSROOT}" STREQUAL "")
            message(FATAL_ERROR "CMAKE_OSX_SYSROOT is not set")
        endif()

        set(sdk_flags "-sdk" "${CMAKE_OSX_SYSROOT}")
    else()
        set(sdk_flags)
    endif()

    if("${SWIFT_IMPORT_HEADERS}" STREQUAL "")
        set(import_flags)
    else()
        set(import_flags "-import-objc-header")
        foreach(header ${SWIFT_IMPORT_HEADERS})
            list(APPEND import_flags "${header}")
        endforeach()
    endif()

    # workaround for bug in swift compiler for linux with empty structs
    if(SWIFT_NODEBUG)
        set(real_debug_flags)
    else()
        set(real_debug_flags "${CMAKE_SWIFT_DEBUG_FLAGS}")
    endif()

    if("${SWIFT_ADD_OBJECT_MODULE_LINK_NAME}" STREQUAL "")
        set(module_link_name_flags)
    else()
        set(module_link_name_flags "-module-link-name" "${SWIFT_ADD_OBJECT_MODULE_LINK_NAME}")
    endif()

    set(c_flags)
    foreach(flag ${SWIFT_ADD_OBJECT_CFLAGS})
        list(APPEND c_flags "-Xcc" "${flag}")
    endforeach()
        
    if("${target_type}" STREQUAL "INTERFACE")
        set(target_include_dirs_property INTERFACE_INCLUDE_DIRECTORIES)
    else()
        set(target_include_dirs_property INCLUDE_DIRECTORIES)
    endif()
    
    if(NOT "${target_name}" STREQUAL "")
        set(target_include_dirs "$<TARGET_PROPERTY:${target_name},${target_include_dirs_property}>")
        set(target_include_flags "$<$<BOOL:${target_include_dirs}>:-I$<JOIN:${target_include_dirs},;-I>>")    
    else()
        set(target_include_flags)    
    endif()

    if(NOT "${target_name}" STREQUAL "" AND NOT "${target_type}" STREQUAL "INTERFACE")
        set(compile_options_flags "$<TARGET_PROPERTY:${target_name},COMPILE_OPTIONS>")
    else()
        set(compile_options_flags)
    endif()

    # adding rule for building swift sources
    # !!! Always clear "clang module cahce" directory to avoid cool side effects!    
    add_custom_command(OUTPUT ${SWIFT_ADD_OBJECT_OUTPUT} ${SWIFT_ADD_OBJECT_MODULE_OUTPUT}
                       COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${mcache_dir}"
                       COMMAND "${CMAKE_SWIFT_COMPILER}" "-c" "-o" "${SWIFT_ADD_OBJECT_OUTPUT}"
                               "-no-link-objc-runtime" ${module_name_flags}
                               ${module_link_name_flags} "-force-single-frontend-invocation"
                               "-target" "${CMAKE_SWIFT_TARGET_TRIPLE}"
                               "-module-cache-path" "${mcache_dir}"                               
                               ${real_debug_flags} ${CMAKE_SWIFT_OPT_FLAGS}
                               ${include_flags}
                               "${target_include_flags}"
                               ${sdk_flags}
                               ${import_flags}
                               ${SWIFT_FLAGS}
                               ${SWIFT_ADD_OBJECT_SWIFT_FLAGS}
                               ${compile_options_flags}
                               ${c_flags}                          
                               ${sources}
                       DEPENDS ${sources} ${dependencies}
                       COMMAND_EXPAND_LISTS)
endfunction()

# Adds common swift link flags to target
function(swift_add_link_flags target)
    get_target_property(target_type ${target} TYPE)    
    
    set(public_flags)
    set(private_flags)

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        # use gold linker
        list(APPEND private_flags "-fuse-ld=gold")
        list(APPEND public_flags "-Wl,--build-id=sha1")                
    endif()
    list(APPEND private_flags "-L${CMAKE_SWIFT_LIBRARY_PATH}")
        
    if(SWIFT_OBJC_INTEROP)
        list(APPEND private_flags "objc")        
    endif()

    if("${target_type}" STREQUAL "INTERFACE_LIBRARY")
        target_link_libraries(${target} INTERFACE ${public_flags} ${private_flags})
    else()
        target_link_libraries(${target} PUBLIC ${public_flags})
        target_link_libraries(${target} PRIVATE ${private_flags})
    endif()

endfunction()


# Adds shared and executable swift link flags to target
function(swift_add_shared_exe_link_flags target)
#    # swift.ld linker script is required for protocol conformances section
#    if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR
#        "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
#        target_link_libraries(${target} PRIVATE
#                              "-Xlinker" "-T"
#                              "-Xlinker" "${CMAKE_SWIFT_LIBRARY_PATH}/swift.ld")
#    endif()
endfunction()


# Adds swift_begin/swift_end objects to the list
function(swift_add_begin_end_objects list_name)
    set(objects ${${list_name}})

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        set(rt_object)
    else()
        if("${SWIFT_RT_O}" STREQUAL "")
            set(rt_object "${CMAKE_SWIFT_LIBRARY_PATH}/swiftrt.o")
        else()
            set(rt_object "${SWIFT_RT_O}")
        endif()

        set(objects ${objects} "${rt_object}")
    endif()

    set(${list_name} ${objects} PARENT_SCOPE)
endfunction()


# Adds swift library linked from swift objects
function(swift_add_library_from_objects name type)
    set(options NO_AUTOLINK)
    set(one_args)
    set(multi_args OBJECTS LIBRARIES)
    cmake_parse_arguments(SWIFT_ADD_LIBRARY_FROM_OBJECTS "${options}" "${one_args}" "${multi_args}" ${ARGN})

    set(objects ${SWIFT_ADD_LIBRARY_FROM_OBJECTS_OBJECTS})
    swift_add_begin_end_objects(objects)

    foreach(obj ${objects})
        set_property(SOURCE "${obj}" PROPERTY GENERATED TRUE)
    endforeach()

    # adding library target
    if("${type}" STREQUAL "INTERFACE")
        add_library(${name} INTERFACE)
        target_sources(${name} INTERFACE ${begin_object} "${objects}" ${end_object})
    else()
        add_library(${name} ${type} ${begin_object} "${objects}" ${end_object})
        set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)    
    endif()

    # saving all recursively linked libraries into target property
    set(all_libs)

    foreach(lib ${SWIFT_ADD_LIBRARY_FROM_OBJECTS_LIBRARIES})
        if(TARGET "${lib}")
            list(APPEND all_libs "${lib}")
        endif()
    endforeach()

    foreach(lib ${SWIFT_ADD_LIBRARY_FROM_OBJECTS_LIBRARIES})
        if(TARGET "${lib}")
            get_property(lib_libs TARGET "${lib}" PROPERTY SWIFT_LIBRARIES)
            list(APPEND all_libs ${lib_libs})
        endif()
    endforeach()

    get_property(targ_type TARGET "${name}" PROPERTY TYPE)
    if(NOT "${targ_type}" STREQUAL "INTERFACE_LIBRARY")
        set_property(TARGET "${name}" PROPERTY SWIFT_LIBRARIES ${all_libs})
    endif()

    set(static_libs_files)
    foreach(lib ${all_libs})
        get_property(type TARGET "${lib}" PROPERTY TYPE)
        if("${type}" STREQUAL "STATIC_LIBRARY")
            list(APPEND static_libs_files "$<TARGET_FILE:${lib}>")
        endif()
    endforeach()

    # adding target for parsing autolink from object files and all linked libraries
    if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin" AND NOT "${SWIFT_ADD_LIBRARY_FROM_OBJECTS_NO_AUTOLINK}")
        add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${name}-autolink"
                           COMMAND "${CMAKE_SWIFT_PATH}/bin/swift-autolink-extract${CMAKE_EXECUTABLE_SUFFIX}"
                                   ${objects} ${static_libs_files} "-o" "${CMAKE_CURRENT_BINARY_DIR}/${name}-autolink"
                           DEPENDS ${objects} ${static_libs_files}
                           COMMAND_EXPAND_LISTS)
        add_custom_target(${name}-autolink-targ ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${name}-autolink")
        add_dependencies(${name} ${name}-autolink-targ)
        set_property(TARGET ${name} APPEND PROPERTY LINK_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${name}-autolink")
        set_property(TARGET ${name} APPEND_STRING PROPERTY LINK_FLAGS "@${CMAKE_CURRENT_BINARY_DIR}/${name}-autolink")
    endif()

    # adding swift flags to library target
    swift_add_link_flags(${name})

    # adding swift shared library flags to target
    if("${type}" STREQUAL "SHARED")
        swift_add_shared_exe_link_flags(${name})
    endif()

    # linking all linked libraries into target
    target_link_libraries(${name} PRIVATE ${SWIFT_ADD_LIBRARY_FROM_OBJECTS_LIBRARIES})
endfunction()


# Adds swift executable linked from swift objects
function(swift_add_executable_from_objects name)
    set(one_args)
    set(multi_args OBJECTS LIBRARIES)
    cmake_parse_arguments(SWIFT_ADD_EXECUTABLE_FROM_OBJECTS "${options}" "${one_args}" "${multi_args}" ${ARGN})

    set(objects ${SWIFT_ADD_EXECUTABLE_FROM_OBJECTS_OBJECTS})

    foreach(obj ${objects})
        set_property(SOURCE "${obj}" PROPERTY GENERATED TRUE)
    endforeach()

    # adding library target
    add_executable(${name} ${begin_object} "${objects}" ${end_object})
    set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)

    # adding swift flags to executable target
    swift_add_link_flags(${name})

    # adding executable swift flags to target
    swift_add_shared_exe_link_flags(${name})

    # linking all linked libraries into target
    target_link_libraries(${name} PRIVATE ${SWIFT_ADD_EXECUTABLE_FROM_OBJECTS_LIBRARIES})
endfunction()


function(swift_add_library_impl name type)
    set(options NO_AUTOLINK)
    set(one_args OUTPUT MODULE_NAME MODULE_LINK_NAME MODULE_PATH TARGET_NAME TARGET_TYPE TARGET)
    set(multi_args SOURCES ADDITIONAL_OBJECTS SWIFT_FLAGS CFLAGS DEPENDS LIBRARIES)
    cmake_parse_arguments(SWIFT_ADD_LIBRARY_NOSTDLIB "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # setting default module link name
    # if("${SWIFT_ADD_LIBRARY_NOSTDLIB_MODULE_LINK_NAME}" STREQUAL "")
    #     set(module_link_name_flags MODULE_LINK_NAME "${name}")
    # else()
    #     set(module_link_name_flags)
    # endif()

    set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/swift-lib-${name}")
    file(MAKE_DIRECTORY "${build_dir}")

    # adding command for building swift object

    set(swift_object "${build_dir}/${name}.o")
    swift_add_object(OUTPUT "${swift_object}" #${module_link_name_flags} 
        TARGET_NAME "${name}" TARGET_TYPE "${type}" ${ARGN})

    set(autolink_flags)
    if("${SWIFT_ADD_LIBRARY_NOSTDLIB_NO_AUTOLINK}")
        set(autolink_flags "NO_AUTOLINK")
    endif()

    # linking library from object + additional objects
    swift_add_library_from_objects("${name}" "${type}" ${autolink_flags}
                                   OBJECTS "${swift_object}" ${SWIFT_ADD_LIBRARY_NOSTDLIB_ADDITIONAL_OBJECTS}
                                   LIBRARIES ${SWIFT_ADD_LIBRARY_NOSTDLIB_LIBRARIES})
endfunction()


# Adds swift library to build without linking system libraries
# Additional global variables:
#       SWIFT_INCLUDE_DIRS - additional include directories
function(swift_add_library_nostdlib name type)
    swift_add_library_impl("${name}" "${type}" NO_AUTOLINK ${ARGN})
endfunction()


# Links standard swift libraries to a target
function(swift_link_std_libs target)
    if(ENABLE_SWIFT_FOUNDATION)
        target_link_libraries(${name} PRIVATE swift${swift_foundation_name} "dispatch")
    endif()

    target_link_libraries(${name} PRIVATE
                          swiftGlibc
                          swiftCore
                          swiftos
                          scadeicu
                          uuid
                          xml2)

    if(SWIFT_OBJC_INTEROP)
        target_link_libraries(${name} PRIVATE
                              swiftFoundation
                              swiftObjectiveC
                              Foundation)
                             
    endif()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        target_link_libraries(${name} PRIVATE swiftSwiftOnoneSupport)
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
        target_link_libraries(${name} PRIVATE swiftJNI)
    endif()
endfunction()


# Adds swift library to build 
# Additional global variables:
#       SWIFT_INCLUDE_DIRS - additional include directories
function(swift_add_library name type)
    swift_add_library_impl(${name} ${type} ${ARGN})
    if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        swift_link_std_libs(${name})
    endif()
endfunction()

# Adds swift executable to build 
# Additional global variables:
#       SWIFT_INCLUDE_DIRS - additional include directories
function(swift_add_executable name)
    set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/swift-exe-${name}")
    file(MAKE_DIRECTORY "${build_dir}")

    cmake_parse_arguments(SWIFT_ADD_EXECUTABLE "" "MODULE_LINK_NAME" "LIBRARIES" ${ARGN})

    # setting default module link name
    if("${SWIFT_ADD_EXECUTABLE_MODULE_LINK_NAME}" STREQUAL "")
        set(module_link_name_flags MODULE_LINK_NAME "${name}")
    else()
        set(module_link_name_flags)
    endif()

    # adding command for building swift object
    set(swift_object "${build_dir}/${name}.o")
    swift_add_object(OUTPUT "${swift_object}" ${module_link_name_flags} 
        TARGET_NAME "${name}" TARGET_TYPE EXECUTABLE ${ARGN})

    swift_add_executable_from_objects("${name}"
                                      OBJECTS "${swift_object}"
                                      LIBRARIES ${SWIFT_ADD_EXECUTABLE_LIBRARIES})
    if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
      swift_link_std_libs(${name})
    endif()
endfunction()


# Recursively adds all dependencies for specified target
function(swift_add_spm_target_dependencies res_var targ)
    set(deps ${swift_add_spm_target_dependencies_${targ}})
    while(TRUE)
        set(new_deps)
        foreach(dep ${deps})
            set(dep_deps ${swift_add_spm_target_dependencies_${dep}})
            foreach(new_dep ${dep_deps})
                list(FIND deps "${new_dep}" res)
                if("${res}" EQUAL "-1")
                    list(APPEND new_deps "${new_dep}")
                endif()
            endforeach()
        endforeach()

        list(APPEND deps ${new_deps})
        if("${new_deps}" STREQUAL "")
            break()
        endif()
    endwhile()
    set(${res_var} ${deps} PARENT_SCOPE)
endfunction()

# Common implementation for adding SPM pacakges for v3 and v4
function(swift_add_spm_impl package_name)
    # parsing options
    set(options)
    set(one_args)
    set(multi_args TARGETS EXECUTABLES LIBRARIES EXTERNAL_LIBRARIES SWIFT_FLAGS)
    cmake_parse_arguments(SWIFT_ADD_SPM_IMPL "${options}" "${one_args}" "${multi_args}" ${ARGN})

    set(targets ${SWIFT_ADD_SPM_IMPL_TARGETS})
    set(executables ${SWIFT_ADD_SPM_IMPL_EXECUTABLES})
    set(libraries ${SWIFT_ADD_SPM_IMPL_LIBRARIES})
    set(external_libraries ${SWIFT_ADD_SPM_IMPL_EXTERNAL_LIBRARIES})

    # creating build directory
    set(package_build_dir "${CMAKE_CURRENT_BINARY_DIR}/spm-deps")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/spm-deps")

    # checking for each target if it contains swift module / native code / include dir
    # and generating module.modulemap for all targets that meet requirements for autogen
    foreach(targ ${targets})
        set(targ_path "${swift_add_spm_target_path_${targ}}")

        file(GLOB_RECURSE sources LIST_DIRECTORIES FALSE "${targ_path}/*.swift")
        if("${sources}" STREQUAL "")
            set(targ_contains_swift_module_${targ} FALSE)
        else()
            set(targ_contains_swift_module_${targ} TRUE)
        endif()

        file(GLOB_RECURSE sources LIST_DIRECTORIES FALSE
             "${targ_path}/*.mm" "${targ_path}/*.m"
             "${targ_path}/*.cpp" "${targ_path}/*.c" "${targ_path}/*.cxx")
        if("${sources}" STREQUAL "")
            set(targ_contains_native_code_${targ} FALSE)
        else()
            set(targ_contains_native_code_${targ} TRUE)
        endif()

        # checking if target contains include directory
        if(EXISTS "${targ_path}/include")
            set(swift_add_spm_target_has_include_${targ} TRUE)
            set(swift_add_spm_target_has_module_map_${targ} FALSE)

            # checking if module.modulemap already exists in include directory
            if(NOT EXISTS "${targ_path}/include/module.modulemap")
                set(umbrella)
                file(GLOB files LIST_DIRECTORIES TRUE RELATIVE "${targ_path}/include" "${targ_path}/include/*")
                list(LENGTH files res)
                if("${res}" EQUAL "1")
                    if(IS_DIRECTORY "${targ_path}/include/${files}")
                        set(umbrella "${targ_path}/include/${files}")
                    else()
                        # include contains single header that should be umbrella header
                        set(umbrella "${targ_path}/include")
                    endif()
                else()
                    set(have_subdirs FALSE)
                    foreach(sub ${files})
                        if(IS_DIRECTORY "${sub}")
                            set(have_subdirs TRUE)
                            break()
                        endif()
                    endforeach()

                    if(NOT "${have_subdirs}")
                        set(umbrella "${targ_path}/include")
                    endif()
                endif()

                if(NOT "${umbrella}" STREQUAL "")
                    # creating module map for umbrella header or directory
                    message(STATUS "Target ${targ} umbrella: ${umbrella}")

                    set(mmap "module ${targ} {\n")
                    set(mmap "${mmap}    umbrella \"${umbrella}\"\n")
                    set(mmap "${mmap}    export *\n")
                    set(mmap "${mmap}}")
                    file(MAKE_DIRECTORY "${package_build_dir}/${targ}-include")
                    file(WRITE "${package_build_dir}/${targ}-include/module.modulemap" "${mmap}")

                    set(swift_add_spm_target_has_module_map_${targ} TRUE)
                endif()
            endif()
        else()
            set(swift_add_spm_target_has_include_${targ} FALSE)
        endif()
    endforeach()

    # Adding objects for all targets
    foreach(targ ${targets})
        set(targ_path "${swift_add_spm_target_path_${targ}}")
        set(targ_build_dir "${package_build_dir}")

        file(GLOB_RECURSE sources LIST_DIRECTORIES FALSE "${targ_path}/*.swift")

        # building list of all target dependencies

        swift_add_spm_target_dependencies(deps "${targ}")

        set(deps_include_dirs)
        set(deps_libs)

        # creating interface library that contain all dependencies for specified target
        add_library(${package_name}-${targ}-dependencies INTERFACE)

        # building list of dependency libraries
        foreach(dep ${deps})
            list(FIND targets "${dep}" res)
            if("${res}" EQUAL "-1")
                # dependency is an external dependency. There should be existing library for it
                target_link_libraries(${package_name}-${targ}-dependencies INTERFACE "${dep}")
            endif()
        endforeach()

        # building list of include dirs of targets containing native code
        foreach(dep ${deps} ${targ})
            list(FIND targets "${dep}" res)
            if(NOT "${res}" EQUAL "-1")
                if("${swift_add_spm_target_has_include_${dep}}")
                    set(dep_path "${swift_add_spm_target_path_${dep}}")
                    list(APPEND deps_include_dirs "${dep_path}/include")
                endif()

                if("${swift_add_spm_target_has_module_map_${dep}}")
                    set(mod_path "${package_build_dir}/${dep}-include")
                    list(APPEND deps_include_dirs "${mod_path}")
                endif()
            endif()
        endforeach()

        # adding external libraries to dependencies interface library
        foreach(lib ${external_libraries})
            target_link_libraries(${package_name}-${targ}-dependencies INTERFACE "${lib}")
        endforeach()


        if("${targ_contains_swift_module_${targ}}")
            # target contains swift module

            # building list of swift dependency modules and include dirs
            set(deps_modules)
            foreach(dep ${deps})
                list(FIND targets "${dep}" res)
                if(NOT "${res}" EQUAL "-1")
                    # dependency is a target from this package, checking if it contains swift module
                    if("${targ_contains_swift_module_${dep}}")
                        list(APPEND deps_modules "${package_build_dir}/${dep}.swiftmodule")
                        list(APPEND deps_include_dirs "-I${package_build_dir}")
                    endif()
                endif()
            endforeach()
            

            if(EXISTS "${targ_path}/main.swift")
                set(lib_flags)
            else()
                set(lib_flags "-parse-as-library")
            endif()

            set(include_flags)
            foreach(idir ${deps_include_dirs})
                list(APPEND include_flags "-I${idir}")
            endforeach()

            file(MAKE_DIRECTORY "${targ_build_dir}")
            swift_add_object(OUTPUT "${targ_build_dir}/${targ}.o"
                             TARGET_NAME "${package_name}-${targ}-dependencies"
                             MODULE_NAME "${targ}"
                             MODULE_PATH "${targ_build_dir}/${targ}.swiftmodule"
                             TARGET_TYPE INTERFACE
                             SOURCES ${sources}
                             DEPENDS ${deps_modules} ${package_deps}
                             SWIFT_FLAGS ${lib_flags} ${include_flags} ${SWIFT_ADD_SPM_IMPL_SWIFT_FLAGS} "-D" "SWIFT_PACKAGE")

        elseif("${targ_contains_native_code_${targ}}")
            file(GLOB_RECURSE sources LIST_DIRECTORIES FALSE
                 "${targ_path}/*.mm" "${targ_path}/*.m"
                 "${targ_path}/*.cpp" "${targ_path}/*.c" "${targ_path}/*.cxx")

            add_library(${package_name}-${targ}-objects OBJECT ${sources})
            target_include_directories(${package_name}-${targ}-objects PRIVATE ${deps_include_dirs})
            target_include_directories(${package_name}-${targ}-objects PRIVATE "${CMAKE_SWIFT_LIBRARY_INCLUDE_PATH}")

            target_compile_options(${package_name}-${targ}-objects PRIVATE "-fmodules" "-fblocks")
            if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
                target_compile_options(${package_name}-${targ}-objects PRIVATE "-fobjc-runtime=gnustep" "-fobjc-legacy-dispatch")
                if("${ENABLE_SWIFT_FOUNDATION}")
                    target_compile_definitions(${package_name}-${targ}-objects PRIVATE "ENABLE_SWIFT_FOUNDATION=1")
                endif()
            endif()

            if("${CMAKE_SYSTEM_NAME}" STREQUAL "Android")
                target_include_directories(${package_name}-${targ}-objects PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/lib/android/include")
            endif()
        endif()
    endforeach()

    # Adding all libraries
    foreach(lib ${libraries})
        # building list of all dependencies
        set(dep_libs)
        set(dep_targets)
        set(objects)

        set(lib_targets ${swift_add_spm_product_targets_${lib}})
        set(deps)
        foreach(targ ${lib_targets})
            swift_add_spm_target_dependencies(targ_deps "${targ}")
            foreach(targ_dep ${targ_deps} ${targ})
                list(FIND deps "${targ_dep}" res)
                if("${res}" EQUAL "-1")
                    list(APPEND deps ${targ_dep})
                endif()
            endforeach()
        endforeach()

        foreach(dep ${deps})
            list(FIND targets "${dep}" res)
            if("${res}" STREQUAL "-1")
                # depndenct is an extternal dependency. Library with same name should exist
                list(APPEND dep_libs "${dep}")
            else()
                # if dependency is a target from same package then we should link object files

                if("${targ_contains_swift_module_${dep}}")
                    list(APPEND objects "${package_build_dir}/${dep}.o")
                elseif("${targ_contains_native_code_${dep}}")
                    list(APPEND objects "$<TARGET_OBJECTS:${package_name}-${dep}-objects>")
                endif()
            endif()
        endforeach()

        set(lib_type "${swift_add_spm_library_type_${lib}}")
        swift_add_library_from_objects("${lib}" "${lib_type}" NO_AUTOLINK OBJECTS ${objects} LIBRARIES ${dep_libs})

        # linking all external libraries
        foreach(elib ${external_libraries})
            target_link_libraries("${lib}" PRIVATE "${elib}")
        endforeach()

        # Adding paths to all .swiftmodule files into list of interface include
        # directories of library
        target_include_directories("${lib}" INTERFACE "${package_build_dir}")
        # foreach(dep ${dep_targets})
        #    target_include_directories("${lib}" INTERFACE "${package_build_dir}/${dep}")
        # endforeach()
    endforeach()

    # Adding all executables
    foreach(exe ${executables})
        # building list of all dependencies
        set(dep_libs)
        set(dep_targets)
        set(objects)

        set(exe_targets ${swift_add_spm_product_targets_${exe}})
        set(deps)
        foreach(targ ${exe_targets})
            swift_add_spm_target_dependencies(targ_deps "${targ}")
            list(APPEND deps "${targ}")
            list(APPEND deps ${targ_deps})
        endforeach()

        foreach(dep ${deps})
            list(FIND targets "${dep}" res)
            if("${res}" STREQUAL "-1")
                # depndenct is an extternal dependency. Library with same name should exist
                list(APPEND dep_libs "${dep}")
            else()
                # if dependency is a target from same package then we should link object file
                list(APPEND dep_targets "${dep}")
                list(APPEND objects "${package_build_dir}/${dep}.o")
            endif()
        endforeach()

        swift_add_executable_from_objects("${exe}" OBJECTS ${objects} LIBRARIES ${dep_libs})

        # linking all external libraries
        foreach(elib ${external_libraries})
            target_link_libraries("${exe}" PRIVATE "${elib}")
        endforeach()
    endforeach()
endfunction()

# Adds all targets from SPM v3 Package
function(swift_add_spm_v3 path desc)
    # parsing options
    set(options)
    set(one_args)
    set(multi_args LIBRARIES SWIFT_FLAGS)
    cmake_parse_arguments(SWIFT_ADD_SPM_V3 "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # splitting lines in description
    string(REPLACE "\n" ";" lines "${desc}")

    set(line_idx 0)
    list(LENGTH lines lines_count)

    # parsing package name
    list(GET lines "${line_idx}" package_name)
    math(EXPR line_idx "${line_idx} + 1")
    message(STATUS "Package name: ${package_name}")

    # scanning targets in Sources directory

    set(targets)
    set(executables)
    set(source_dirs_names "Sources" "Source" "srcs" "src")

    foreach(src_dir_name ${source_dirs_names})
        set(source_path "${path}/${src_dir_name}")

        # checking if package contains top level target right inside source dir
        file(GLOB swift_srcs LIST_DIRECTORIES FALSE RELATIVE "${source_path}" "${source_path}/*.swift")
        if(NOT "${swift_srcs}" STREQUAL "")
            list(APPEND targets "${package_name}")
            set("swift_add_spm_target_path_${package_name}" "${source_path}")
        else()
            file(GLOB subdirs LIST_DIRECTORIES TRUE RELATIVE "${source_path}" "${source_path}/*")
            foreach(subdir ${subdirs})
                list(APPEND targets "${subdir}")
                set("swift_add_spm_target_path_${subdir}" "${source_path}/${subdir}")
            endforeach()
        endif()
    endforeach()

    foreach(targ ${targets})
        set("swift_add_spm_target_dependencies_${subdir}")
        set(targ_path "${swift_add_spm_target_path_${targ}}")

        message(STATUS "Target: ${targ}: ${targ_path}")

        # checking if target is executable (contains main.swift)
        if(EXISTS "${targ_path}/main.swift")
            message(STATUS "Executable target: ${targ}")
            list(APPEND executables "${targ}")
            set("swift_add_spm_product_targets_${targ}" "${targ}")
        endif()
    endforeach()


    # parsing package dependencies
    set(package_deps)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        if("${line}" STREQUAL "TARGETS")
            break()
        endif()

        message(STATUS "Package dependency: ${line}")
        list(APPEND package_deps "${line}")
    endwhile()

    # Parsing target dependencies
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        # splitting target line into list
        string(REPLACE " " ";" line_items "${line}")
        list(LENGTH line_items line_items_count)

        # getting target name
        list(GET line_items 0 target_name)

        # getting target dependencies
        set(line_item_idx "1")
        set(target_deps)
        while("${line_item_idx}" LESS "${line_items_count}")
            list(GET line_items "${line_item_idx}" dep)
            list(APPEND target_deps "${dep}")
            math(EXPR line_item_idx "${line_item_idx} + 1")
        endwhile()

        message(STATUS "Target dependencies: ${target_name}: ${target_deps}")
        set("swift_add_spm_target_dependencies_${target_name}" ${target_deps})
    endwhile()

    # adding all package dependencies into list of dependencies for all targets
    foreach(targ ${targets})
        list(APPEND "swift_add_spm_target_dependencies_${targ}" ${package_deps})
    endforeach()

    # v3 pacage contains single static library that includes all targets that are not
    # executables
    set(libraries "${package_name}")
    set("swift_add_spm_product_targets_${package_name}")
    set("swift_add_spm_library_type_${package_name}" "STATIC")
    foreach(targ ${targets})
        list(FIND executables "${targ}" res)
        if("${res}" EQUAL "-1")
            list(APPEND "swift_add_spm_product_targets_${package_name}" "${targ}")
        endif()
    endforeach()


    swift_add_spm_impl("${package_name}"
                       TARGETS ${targets}
                       EXECUTABLES ${executables}
                       LIBRARIES ${libraries}
                       EXTERNAL_LIBRARIES ${SWIFT_ADD_SPM_V3_LIBRARIES}
                       SWIFT_FLAGS ${SWIFT_ADD_SPM_V3_SWIFT_FLAGS})
endfunction()

# Adds all targets from SPM v4 Package
function(swift_add_spm_v4 path desc)
    # parsing options
    set(options)
    set(one_args)
    set(multi_args LIBRARIES SWIFT_FLAGS)
    cmake_parse_arguments(SWIFT_ADD_SPM_V4 "${options}" "${one_args}" "${multi_args}" ${ARGN})

    # splitting lines in description
    string(REPLACE "\n" ";" lines "${desc}")

    set(line_idx 0)
    list(LENGTH lines lines_count)

    # parsing package name
    list(GET lines "${line_idx}" package_name)
    math(EXPR line_idx "${line_idx} + 1")
    message(STATUS "Package name: ${package_name}")

    # parsing package dependencies
    set(package_deps)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        if("${line}" STREQUAL "TARGETS")
            break()
        endif()

        message(STATUS "Package dependency: ${line}")
        list(APPEND package_deps "${line}")
    endwhile()

    # Parsing targets
    set(targets)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        if("${line}" STREQUAL "PRODUCTS")
            break()
        endif()

        # splitting target line into list
        string(REPLACE " " ";" line_items "${line}")
        list(LENGTH line_items line_items_count)

        # getting target name
        list(GET line_items 0 target_name)

        # getting target sources path
        list(GET line_items 1 target_path)
        if("${target_path}" STREQUAL "<empty>")
            set(target_path "")
        else()
            set(target_path "${path}/${target_path}")
            if(NOT EXISTS "${target_path}")
                message(FATAL_ERROR "Source path fot target '${target_name}' does not exist: '${target_path}'")
            endif()
        endif()

        # getting target dependencies
        set(line_item_idx "2")
        set(target_deps)
        while("${line_item_idx}" LESS "${line_items_count}")
            list(GET line_items "${line_item_idx}" dep)
            list(APPEND target_deps "${dep}")
            math(EXPR line_item_idx "${line_item_idx} + 1")
        endwhile()

        list(APPEND targets "${target_name}")
        set("swift_add_spm_target_dependencies_${target_name}" ${target_deps})

        # looking for target source directory if not set
        if("${target_path}" STREQUAL "")
            set(source_dirs_names "Sources" "Source" "srcs" "src")
            set(target_path)
            foreach(source_dir ${source_dirs_names})
                if(EXISTS "${path}/${source_dir}/${target_name}" AND
                   IS_DIRECTORY "${path}/${source_dir}/${target_name}")
                    set(target_path "${path}/${source_dir}/${target_name}")
                    break()
                endif()
            endforeach()
        endif()

        if("${target_path}" STREQUAL "")
            message(FATAL_ERROR "Can't find source path for target '${target_name}'")
        endif()

        set("swift_add_spm_target_path_${target_name}" "${target_path}")
        message(STATUS "Target: ${target_name}: ${target_path}, DEPENDENCIES: ${target_deps}")
    endwhile()

    # Parsing products
    set(products)
    set(libraries)
    set(executables)
    while(TRUE)
        if("${line_idx}" EQUAL "${lines_count}")
            break()
        endif()

        list(GET lines "${line_idx}" line)
        math(EXPR line_idx "${line_idx} + 1")

        # splitting product line into list
        string(REPLACE " " ";" line_items "${line}")
        list(LENGTH line_items line_items_count)

        # getting product name
        list(GET line_items 0 product_name)

        # getting product type
        list(GET line_items 1 product_type)

        if("${product_type}" STREQUAL "EXECUTABLE")
            list(APPEND executables "${product_name}")
        elseif("${product_type}" STREQUAL "STATIC_LIBRARY")
            list(APPEND libraries "${product_name}")
            set("swift_add_spm_library_type_${product_name}" "STATIC")
        elseif("${product_type}" STREQUAL "DYNAMIC_LIBRARY")
            list(APPEND libraries "${product_name}")
            set("swift_add_spm_library_type_${product_name}" "SHARED")
        endif()

        # getting product targets
        set(line_item_idx "2")
        set(product_targets)
        while("${line_item_idx}" LESS "${line_items_count}")
            list(GET line_items "${line_item_idx}" targ)
            list(APPEND product_targets "${targ}")
            math(EXPR line_item_idx "${line_item_idx} + 1")
        endwhile()

        message(STATUS "Product: ${product_name} ${product_type}: ${product_targets}")
        list(APPEND products "${product_name}")
        set("swift_add_spm_product_type_${product_name}" ${product_type})
        set("swift_add_spm_product_targets_${product_name}" ${product_targets})
    endwhile()

    swift_add_spm_impl("${package_name}"
                       TARGETS ${targets}
                       EXECUTABLES ${executables}
                       LIBRARIES ${libraries}
                       EXTERNAL_LIBRARIES ${SWIFT_ADD_SPM_V4_LIBRARIES}
                       SWIFT_FLAGS ${SWIFT_ADD_SPM_V4_SWIFT_FLAGS})
endfunction()

# Adds all targets from SPM Package
function(swift_add_spm)
    if("${CMAKE_HOST_SWIFT_PATH}" STREQUAL "")
        message(FATAL_ERROR "Path to system swift compiler is not set")
    endif()

    # checking if we have single package in list of packages (for compatibility version)
    list(LENGTH ARGN count)
    set(is_single_package FALSE)
    if("${count}" EQUAL "1")
        set(is_single_package TRUE)
        set(packages ${ARGN})
    else()
        set(options)
        set(one_args)
        set(multi_args PACKAGES LIBRARIES SWIFT_FLAGS)
        cmake_parse_arguments(SWIFT_ADD_SPM "${options}" "${one_args}" "${multi_args}" ${ARGN})
        set(packages ${SWIFT_ADD_SPM_PACKAGES})
    endif()

    # building list of package names
    set(pacakge_names)
    foreach(path ${packages})
        get_filename_component(path_name "${path}" NAME)
        list(APPEND package_names "${path_name}")
    endforeach()

    # dumping all packages and reading list of dependencies
    foreach(path ${packages})
        # checking that package path exists
        if(NOT EXISTS "${path}")
            message(FATAL_ERROR "Package path does not exist: '${path}'")
        endif()

        # checking that package path is a directory
        if(NOT IS_DIRECTORY "${path}")
            message(FATAL_ERROR "Package path is not a directory: '${path}'")
        endif()

        get_filename_component(path_name "${path}" NAME)

        # getting version of package manager for specified package
        set(swift_tool_path "${CMAKE_HOST_SWIFT_PATH}/bin/swift")
        execute_process(COMMAND "${swift_tool_path}" "package" "tools-version"
                        WORKING_DIRECTORY "${path}"
                        RESULT_VARIABLE res
                        OUTPUT_VARIABLE out
                        ERROR_VARIABLE out
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        ERROR_STRIP_TRAILING_WHITESPACE)
        if(NOT "${res}" EQUAL "0")
            message(FATAL_ERROR "Can't detect swift tools version for package located in '${path}':\n${out}")
        endif()

        # detecting tools version for package
        set(tools_version_${path_name} "4")
        string(SUBSTRING "${out}" 0 1 v)
        if("${v}" STREQUAL "4" OR
           "${v}" STREQUAL "4" OR
           "${v}" STREQUAL "4")
            message(STATUS "Found SPM 4 package in '${path}'")
        elseif("${v}" STREQUAL "3" OR
               "${v}" STREQUAL "3" OR
               "${v}" STREQUAL "3")
            message(STATUS "Found SPM 3 package in '${path}'")
            set(tools_version_${path_name} "3")
        else()
            message(FATAL_ERROR "Unknown swift tools version for package '${path}': ${out}")
        endif()

        set(package_json "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.json")
        set(package_out "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out")

        # dumping package only if .out file does not exist or older than Pacakge.swift
        set(do_dump TRUE)
        if(EXISTS "${package_out}")
            file(TIMESTAMP "${package_out}" out_timestamp "%s")
            file(TIMESTAMP "${path}/Package.swift" package_swift_timestamp "%s")

            if(NOT "${out_timestamp}" STREQUAL "" AND
               NOT "${package_swift_timestamp}" STREQUAL "")
                if("${package_swift_timestamp}" LESS "${out_timestamp}")
                    set(do_dump FALSE)
                endif()
            endif()
        endif()

        if("${do_dump}")
            # dumping package JSON description using swift package dump-package
            execute_process(COMMAND "${swift_tool_path}" "package" "dump-package"
                            WORKING_DIRECTORY "${path}"
                            RESULT_VARIABLE res
                            ERROR_VARIABLE err
                            OUTPUT_FILE "${package_json}"
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_STRIP_TRAILING_WHITESPACE)
            if(NOT "${res}" EQUAL "0")
                message(FATAL_ERROR "Can't dump package located in '${path}':\n${err}")
            endif()

            # dumping package from JSON description
            set(dump_script_path "${SWIFT_CMAKE_LIST_DIR}/dump_package_v${tools_version_${path_name}}.swift")
            execute_process(COMMAND "${swift_tool_path}" "${dump_script_path}"
                            WORKING_DIRECTORY "${path}"
                            RESULT_VARIABLE res
                            ERROR_VARIABLE err
                            INPUT_FILE "${package_json}"
                            OUTPUT_FILE "${package_out}"
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_STRIP_TRAILING_WHITESPACE)
            if(NOT "${res}" EQUAL "0")
                message(FATAL_ERROR "Can't convert JSON description for package located at '${path}':\n${err}")
            endif()
        endif()

        # reading dependencies for package
        set(package_deps_${path_name})

        file(READ "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out" out)
        string(STRIP "${out}" out)
        string(REPLACE "\n" ";" lines "${out}")
        list(LENGTH lines lines_count)

        set(line_idx 1)
        while(TRUE)
            if("${line_idx}" EQUAL "${lines_count}")
                break()
            endif()

            list(GET lines "${line_idx}" line)
            math(EXPR line_idx "${line_idx} + 1")

            if("${line}" STREQUAL "TARGETS")
                break()
            endif()

            list(APPEND package_deps_${path_name} "${line}")
        endwhile()

        message(STATUS "Package ${path_name} dependencies: ${package_deps_${path_name}}")

        # checking package depdendencies if not in compatibility mode
        if(NOT "${is_single_package}")
            foreach(dep ${package_deps_${path_name}})
                list(FIND package_names "${dep}" idx)
                if("${idx}" EQUAL "-1")
                    message(FATAL_ERROR "Package located in path '${path}' has dependency '${dep}' that is not in the list of packages to be built")
                endif()
            endforeach()
        endif()
    endforeach()

    if("${is_single_pacakge}")
        # always add single package (for compatibility mode)

        get_filename_component(path_name "${path}" NAME)

        file(READ "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out" out)
        string(STRIP "${out}" out)

        if("${tools_version_${path_name}}" STREQUAL "3")
            swift_add_spm_v3("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
        else()
            swift_add_spm_v4("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
        endif()
    else()
        # building all packages
        set(packages_to_build ${packages})
        set(package_names_to_build ${package_names})

        while(TRUE)
            # checking for empty list to build
            list(LENGTH packages_to_build count)
            if("${count}" EQUAL "0")
                break()
            endif()

            # building all packages with built dependencies
            foreach(path ${packages_to_build})
                get_filename_component(path_name "${path}" NAME)
                set(deps ${package_deps_${path_name}})
                set(is_ready TRUE)
                foreach(dep ${deps})
                    list(FIND package_names_to_build "${dep}" idx)
                    if(NOT "${idx}" EQUAL "-1")
                        set(is_ready FALSE)
                        break()
                    endif()
                endforeach()

                if("${is_ready}")
                    file(READ "${CMAKE_CURRENT_BINARY_DIR}/dump_package-${path_name}.out" out)
                    string(STRIP "${out}" out)

                    if("${tools_version_${path_name}}" STREQUAL "3")
                        swift_add_spm_v3("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
                    else()
                        swift_add_spm_v4("${path}" "${out}" LIBRARIES ${SWIFT_ADD_SPM_LIBRARIES} SWIFT_FLAGS ${SWIFT_ADD_SPM_SWIFT_FLAGS})
                    endif()
                    
                    list(REMOVE_ITEM packages_to_build "${path}")
                    list(REMOVE_ITEM package_names_to_build "${path_name}")
                endif()
            endforeach()
        endwhile()
    endif()
endfunction()

