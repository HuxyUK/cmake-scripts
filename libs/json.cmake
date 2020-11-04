#------------------------------------------------------------------------------
# JSON For Modern C++
# https://github.com/nlohmann/json
#------------------------------------------------------------------------------

## To enable JSON support override the default option setting
## set(ENABLE_JSON  ON  CACHE BOOL "Adds JSON Support" FORCE)

OPTION(ENABLE_JSON "Adds JSON to the Project" OFF)

if( ENABLE_JSON )
  message(STATUS  "JSON:")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  
  include(FetchContent)
  message(STATUS "+ FETCHING JSON....")
  FetchContent_Declare(
      json
      URL https://github.com/nlohmann/json/releases/download/v3.5.0/include.zip)
  
  FetchContent_GetProperties(json)
  if(NOT json_POPULATED)
    message(STATUS "+ CONFIGURING JSON....")
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
    FetchContent_Populate(json)
    
    # create a header only library
    add_library(jsonlib INTERFACE)
    target_include_directories(
        jsonlib
        SYSTEM INTERFACE
        ${json_SOURCE_DIR})
    
    message(DEBUG "JSON INCLUDE DIR: ${json_SOURCE_DIR}")
    
    # lets not worry about compile warnings
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
  message(STATUS "+ DONE")
  list(POP_BACK CMAKE_MESSAGE_INDENT)
endif()
