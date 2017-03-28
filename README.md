# CMake Utils
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/tschuchortdev/cmake_utils/issues)

miscellaneous cmake utility functions for file gathering and object library dependency management


## fileRegex
Find files that match a regex pattern and add them to a list.
Replacement for CMake's `file` function.

Options:
  - `RELATIVE_PATHS`: output relative paths into the list
  - `FOLLOW_SYMLINKS`: follow symlinks when traversing subdirectories
  - `RECURSIVE`: traverse subdirectories 
  
Arguments:
  - `INCLUDE`: list of file regex patterns that should be included
  - `EXCLUDE`: list of file regex patterns that should be excluded
  
Example:

    fileRegex(
            outputList 
            RECURSIVE
            FOLLOW_SYMLINKS
            RELATIVE_PATHS
            INCLUDE ".*" 
            EXCLUDE "^.*icon.*\\.png$" "^.*image.*\\.img$")
  
## fileGlob
Find files that match a globbing pattern and add them to a list.
Replacement for CMake's `file` function.

Options:
  - `RELATIVE_PATHS`: output relative paths into the list
  - `FOLLOW_SYMLINKS`: follow symlinks when traversing subdirectories
  - `RECURSIVE`: traverse subdirectories 
  
Arguments:
  - `INCLUDE`: list of file glob patterns that should be included
  - `EXCLUDE`: list of file glob patterns that should be excluded
  
Example:

    fileGlob(
            sources 
            RECURSIVE 
            INCLUDE "*.c*" "*.h*" 
            EXCLUDE "test/*" "temp/*")

## target_link_dependencies
`target_link_dependencies` works similar to `target_link_libraries` except that you can link `OBJECT` libraries directly just as if they were regular libraries. This is very helpful because transitive dependencies, even on third `OBJECT` libraries, are propagated automatically. 

Arguments:
  - `PRIVATE`: list of private dependencied
  - `PUBLIC`: list of public dependencies
  - `INTERFACE`: list of interface dependencies
  
  dependencies specified without a scope are `PRIVATE` by default.
  
Note that `PRIVATE` and `INTERFACE` behave differently for `OBJECT` libraries than they do for regular libraries. Since `OBJECT` libraries are more like a collection of source files, their dependencies are only linked together when the `OBJECT` itself is first linked to a regular library, so `PRIVATE` dependencies will in fact be available to the target, while `INTERFACE` dependencies will also be available to the `OBJECT`. 

Example:
   
    add_library(my_transitive_obj OBJECT "2/test.cpp")
    target_include_directories(my_transitive_obj "1/")
    
    add_library(my_regular_lib "3/test.cpp")
    
    add_library(my_obj OBJECT "3/test.cpp")
    target_include_directories(my_obj "3/")
    target_link_dependencies(my_obj PUBLIC my_transitive_obj my_regular_lib)

    add_executable(my_exe "")
    target_link_dependencies(my_exe PRIVATE my_obj)
  
