OPTION(ENABLE_CLANG_FORMAT "Adds clang-format style as a target" OFF)

find_program(
    CFE NAMES clang-format
    HINTS ${CMAKE_SOURCE_DIR}/tools/*/${PLATFORM}/)

file(GLOB_RECURSE SOURCE_CODE
     LIST_DIRECTORIES FALSE
     CONFIGURE_DEPENDS
     ${PROJECT_SOURCE_DIR}/apps/*.[chi]pp
     ${PROJECT_SOURCE_DIR}/apps/*.[h]
     ${PROJECT_SOURCE_DIR}/source/*.[chi]pp
     ${PROJECT_SOURCE_DIR}/source/*.[ch]
     ${PROJECT_SOURCE_DIR}/include/*.[chi]pp
     ${PROJECT_SOURCE_DIR}/include/*.[ch] )

if(CFE)
  list(APPEND CLANG-FORMAT_ARGS
       -i
       --style=file
       ${SOURCE_CODE}
       )
  
  add_custom_target(
      ClangFormat
      COMMAND "${CFE}" ${CLANG-FORMAT_ARGS}
      COMMENT "running clang-format"
  )
endif()

