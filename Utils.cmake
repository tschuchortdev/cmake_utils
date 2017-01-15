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
