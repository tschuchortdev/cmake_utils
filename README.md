# cmake_utils
miscellaneous cmake utility functions


## fileRegex
Find files that match a regex pattern and add them to a list.
Replacement for CMake's `file` function.

Options:
  - `RELATIVE_PATHS`: output relative paths into the list
  - `FOLLOW_SYMLINKS`: follow symlinks when traversing subdirectories
  - `RECURSIVE': traverse subdirectories 
  
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
  
