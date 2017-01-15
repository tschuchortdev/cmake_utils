# CMake Utils

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/cef8fb7317ce46e694a42389bffac2f2)](https://www.codacy.com/app/t-schuchort/cmake_utils?utm_source=github.com&utm_medium=referral&utm_content=tschuchortdev/cmake_utils&utm_campaign=badger)

miscellaneous cmake utility functions


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
    
