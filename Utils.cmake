include(CMakeParseArguments)

function(fileRegex)
    cmake_parse_arguments(
            ARGS                                        # prefix of output variables
            "RELATIVE_PATHS;FOLLOW_SYMLINKS;RECURSIVE"  # list of names of the boolean arguments (only defined ones will be true)
            ""                                          # list of names of mono-valued arguments
            "INCLUDE;EXCLUDE"                           # list of names of multi-valued arguments (output variables are lists)
            ${ARGN}                                     # arguments of the function to parse, here we take the all original ones
    ) # remaining unparsed arguments can be found in ARGS_UNPARSED_ARGUMENTS

    list(LENGTH ARGS_UNPARSED_ARGUMENTS other_args_size)

    if(NOT other_args_size EQUAL 1)
        message(FATAL_ERROR "fileRegex: must have exactly one argument for output list")
    endif()

    if(ARGS_RECURSIVE)
        set(GLOB_TYPE "GLOB_RECURSE")
    else()
        set(GLOB_TYPE "GLOB")
    endif()

    if(ARGS_RELATIVE_PATHS)
        set(RELATIVE "RELATIVE")
    endif()

    if(ARGS_FOLLOW_SYMLINKS)
        set(FOLLOW_SYMLINKS "FOLLOW_SYMLINKS")
    endif()

    # first accumulate all files
    file(${GLOB_TYPE} all_files "*"
            ${RELATIVE}
            ${FOLLOW_SYMLINKS})

    foreach(file ${all_files})
        foreach(include_pattern ${ARGS_INCLUDE})
            if(${file} MATCHES ${include_pattern})
                list(APPEND files ${file})
            endif()
        endforeach()
    endforeach()

    foreach(file ${files})
        foreach(exlude_pattern ${ARGS_EXCLUDE})
            if(${file} MATCHES ${exclude_pattern})
                list(REMOVE_ITEM files ${file})
            endif()
        endforeach()
    endforeach()


    set(${ARGS_UNPARSED_ARGUMENTS} ${files} PARENT_SCOPE)
endfunction()


function(fileGlob)
    cmake_parse_arguments(
            ARGS                                        # prefix of output variables
            "RELATIVE_PATHS;FOLLOW_SYMLINKS;RECURSIVE"  # list of names of the boolean arguments (only defined ones will be true)
            ""                                          # list of names of mono-valued arguments
            "INCLUDE;EXCLUDE"                           # list of names of multi-valued arguments (output variables are lists)
            ${ARGN}                                     # arguments of the function to parse, here we take the all original ones
    ) # remaining unparsed arguments can be found in ARGS_UNPARSED_ARGUMENTS

    list(LENGTH ARGS_UNPARSED_ARGUMENTS other_args_size)
    if(NOT other_args_size EQUAL 1)
        message(FATAL_ERROR "fileGlob: must have exactly one argument for output list")
    endif()

    if(ARGS_RECURSIVE)
        set(GLOB_TYPE "GLOB_RECURSE")
    else()
        set(GLOB_TYPE "GLOB")
    endif()

    if(ARGS_RELATIVE_PATHS)
        set(RELATIVE "RELATIVE")
    endif()

    if(ARGS_FOLLOW_SYMLINKS)
        set(FOLLOW_SYMLINKS "FOLLOW_SYMLINKS")
    endif()


    file(${GLOB_TYPE} included_files ${ARGS_INCLUDE}
            ${RELATIVE}
            ${FOLLOW_SYMLINKS})

    file(${GLOB_TYPE} excluded_files ${ARGS_EXCLUDE}
            ${RELATIVE}
            ${FOLLOW_SYMLINKS})

    if(excluded_files)
        list(REMOVE_ITEM included_files ${excluded_files})
    endif()

    set(${ARGS_UNPARSED_ARGUMENTS} ${included_files} PARENT_SCOPE)
endfunction()


# Link dependencies to a target. A dependency can be an object, a library, or an exported executable.
# The function replaces target_link_libraries() and can also deal with objects that have transitive dependencies.
# Note that private dependencies of an object dependency are also available in the target, in contrast to
# the behaviour of target_link_libraries().
#
# EXAMPLES:
#
#   target_link_dependencies(my_exe my_lib my_obj) #dependencies are private by default
#
#   target_link_dependencies(my_exe PUBLIC my_lib PRIVATE my_obj)
#
function(target_link_dependencies target)
    cmake_parse_arguments(
            ARGS                        # prefix of output variables
            ""                          # list of names of the boolean arguments (only defined ones will be true)
            ""                          # list of names of mono-valued arguments
            "PRIVATE;PUBLIC;INTERFACE"  # list of names of multi-valued arguments (output variables are lists)
            ${ARGN}                     # arguments of the function to parse, here we take the all original ones
    ) # remaining unparsed arguments can be found in ARGS_UNPARSED_ARGUMENTS

    set(private_libs "${ARGS_PRIVATE};${ARGS_UNPARSED_ARGUMENTS}")
    set(public_libs "${ARGS_PUBLIC}")
    set(interface_libs "${ARGS_INTERFACE}")

    # if target is an object library, save dependency names in target properties
    get_target_property(target_type ${target} TYPE)
    if(${target_type} STREQUAL "OBJECT_LIBRARY")

        foreach(lib ${private_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
                object_link_object(${target} PRIVATE ${lib})
            else()
                object_link_library(${target} PRIVATE ${lib})
            endif()
        endforeach()

        foreach(lib ${public_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
                object_link_object(${target} PUBLIC ${lib})
            else()
                object_link_library(${target} PUBLIC ${lib})
            endif()
        endforeach()

        foreach(lib ${interface_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
                object_link_object(${target} INTERFACE ${lib})
            else()
                object_link_library(${target} INTERFACE ${lib})
            endif()
        endforeach()

    # if target is a regular target (not object)
    else()
        foreach(lib ${private_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
               target_link_object(${target} PRIVATE ${lib})
            else()
                target_link_libraries(${target} PRIVATE ${lib})
            endif()
        endforeach()

        foreach(lib ${public_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
                target_link_object(${target} PUBLIC ${lib})
            else()
                target_link_libraries(${target} PUBLIC ${lib})
            endif()
        endforeach()

        foreach(lib ${interface_libs})
            # if library is an object
            get_target_property(lib_type ${lib} TYPE)
            if(${lib_type} STREQUAL "OBJECT_LIBRARY")
                target_link_object(${target} INTERFACE ${lib})
            else()
                target_link_libraries(${target} INTERFACE ${lib})
            endif()
        endforeach()

    endif()
endfunction()


# link a regular library to an object
#
#    target: target name
#    scope: scope of dependency (PUBLIC, PRIVATE or INTERFACE)
#    lib: library to link
#
function(object_link_library target scope lib)
    target_include_directories(${target} ${scope} $<TARGET_PROPERTY:${lib},INTERFACE_INCLUDE_DIRECTORIES>)
    target_compile_definitions(${target} ${scope} $<TARGET_PROPERTY:${lib},INTERFACE_COMPILE_DEFINITIONS>)
    target_compile_options(${target} ${scope} $<TARGET_PROPERTY:${lib},INTERFACE_COMPILE_OPTIONS>)

    append_target_property(${target} ${scope}_DEPS ${lib})
endfunction()

# link an object to an object
#
#    target: target name
#    scope: scope of dependency (PUBLIC, PRIVATE or INTERFACE)
#    obj: object to link
#
function(object_link_object target scope obj)
    target_sources(
            ${target}
            INTERFACE
                $<TARGET_OBJECTS:${obj}>
                $<TARGET_PROPERTY:${obj},INTERFACE_SOURCES>)

    target_include_directories(${target} PRIVATE $<TARGET_PROPERTY:${obj},INCLUDE_DIRECTORIES>)
    target_include_directories(${target} ${scope} $<TARGET_PROPERTY:${obj},INTERFACE_INCLUDE_DIRECTORIES>)

    target_compile_options(${target} PRIVATE $<TARGET_PROPERTY:${obj},COMPILE_OPTIONS>)
    target_compile_options(${target} ${scope} $<TARGET_PROPERTY:${obj},INTERFACE_COMPILE_OPTIONS>)

    target_compile_definitions(${target} PRIVATE $<TARGET_PROPERTY:${obj},COMPILE_DEFINITIONS>)
    target_compile_definitions(${target} ${scope} $<TARGET_PROPERTY:${obj},INTERFACE_COMPILE_DEFINITIONS>)

    append_target_property(${target} PRIVATE_DEPS $<TARGET_PROPERTY:${obj},PRIVATE_DEPS>)
    append_target_property(${target} ${scope}_DEPS $<TARGET_PROPERTY:${obj},PUBLIC_DEPS>)
    append_target_property(${target} ${scope}_DEPS $<TARGET_PROPERTY:${obj},INTERFACE_DEPS>)
endfunction()

# link an object to a regular target (executable or library but not object or imported)
#
#    target: target name
#    scope: scope of dependency (PUBLIC, PRIVATE or INTERFACE)
#    obj: object to link
#
function(target_link_object target scope obj)
    # add object library as a source file to target
    target_sources(${target} PRIVATE $<TARGET_OBJECTS:${obj}>)
    target_sources(${target} ${scope} $<TARGET_PROPERTY:${obj},INTERFACE_SOURCES>)

    safe_get_target_property(objs_private_deps ${obj} PRIVATE_DEPS)
    safe_get_target_property(objs_public_deps ${obj} PUBLIC_DEPS)
    safe_get_target_property(objs_interface_deps ${obj} INTERFACE_DEPS)
    target_link_libraries(${target} PRIVATE ${private_deps} ${scope} ${objs_public_deps} ${objs_interface_deps} )

    target_include_directories(${target} PRIVATE $<TARGET_PROPERTY:${obj},INCLUDE_DIRECTORIES>)
    target_include_directories(${target} ${scope} $<TARGET_PROPERTY:${obj},INTERFACE_INCLUDE_DIRECTORIES>)

    target_compile_options(${target} PRIVATE $<TARGET_PROPERTY:${lib},COMPILE_OPTIONS>)
    target_compile_options(${target} ${scope} $<TARGET_PROPERTY:${lib},INTERFACE_COMPILE_OPTIONS>)

    target_compile_definitions(${target} PRIVATE $<TARGET_PROPERTY:${lib},COMPILE_DEFINITIONS>)
    target_compile_definitions(${target} ${scope} $<TARGET_PROPERTY:${lib},INTERFACE_COMPILE_DEFINITIONS>)
endfunction()

# returns empty string if target property not found
function(safe_get_target_property result target property)
    get_target_property(val ${target} ${property})
    if("${val}" STREQUAL "val-NOTFOUND")
        set(${result} "")
    else()
        set(${result} ${val})
    endif()
endfunction()

# append to a target property
function(append_target_property target property value)
    safe_get_target_property(old_val ${target} ${property})
    set_target_properties(${target} PROPERTIES ${property} "${old_val};${value}")
endfunction()

