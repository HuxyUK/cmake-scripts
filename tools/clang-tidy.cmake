#------------------------------------------------------------------------------
# Enables Clang-Tidy support.
# Clang-tidy performs static analysis on the codebase to ensure its
# style meets a required standard. The checks can be adjusted using a
# .clang-tidy file. Clang-Tidy can also make attempts to resolve the issues
# automatically. To enable this behaviour set the CLANG_TIDY_FIX option to ON
# v1.0.0
#------------------------------------------------------------------------------
if(CMAKE_VERSION VERSION_GREATER 3.6)
  option(CLANG_TIDY_FIX "Perform fixes for Clang-Tidy" OFF)
  find_program(
      CLANG_TIDY_EXE
      NAMES "clang-tidy"
      DOC "Path to clang-tidy executable"
  )
  
  if(CLANG_TIDY_EXE)
    if(CLANG_TIDY_FIX)
      set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}" "-fix")
    else()
      set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    endif()
  endif()
endif()

###################################
# Clang-Tidy Custom Build Targets #
###################################

## works best with python
include(tools/python)

if(${CMAKE_CXX_PLATFORM_ID} STREQUAL "MinGW")
  set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES OFF)
endif()

## already defined, so skip the heavy lifting
if(TARGET Tidy)
  return()
endif()

find_program(CLANG_TIDY
             NAMES clang-tidy-12 clang-tidy-11 clang-tidy-10 clang-tidy-9 clang-tidy-8 clang-tidy
             HINTS ${CMAKE_SOURCE_DIR}/tools/*/*/ )

if(CLANG_TIDY)
  file(GLOB_RECURSE ALL_CXX_SOURCE_FILES
       ${PROJECT_SOURCE_DIR}/apps/*.[chi]pp
       ${PROJECT_SOURCE_DIR}/apps/*.[h]
       ${PROJECT_SOURCE_DIR}/source/*.[chi]pp
       ${PROJECT_SOURCE_DIR}/source/*.[ch]
       ${PROJECT_SOURCE_DIR}/include/*.[chi]pp
       ${PROJECT_SOURCE_DIR}/include/*.[ch] )
  
  
  #file(GLOB_RECURSE
  #        ALL_CXX_SOURCE_FILES
  #        *.[chi]pp *.[chi]xx *.cc *.hh *.ii *.[CHI]
  #        )
  
  
  find_package(Python3 QUIET COMPONENTS Interpreter )
  
  find_program(RUN_CLANG_TIDY
               NAMES run-clang-tidy.py
               HINTS ${CMAKE_SOURCE_DIR}/tools/*/ )
  
  if(Python3_FOUND AND RUN_CLANG_TIDY)
    include(ProcessorCount)
    ProcessorCount(CPU_CORES)
    
    list(APPEND RUN_CLANG_TIDY_BIN_ARGS
         -clang-tidy-binary ${CLANG_TIDY}
         -p ${CMAKE_BINARY_DIR}
         -quiet
         -format
         -j ${CPU_CORES}
         -extra-arg=\"-std=c++17\"
         -header-filter=".*"           #"\"-header-filter=.*(apps|GameLib|source).*\""
         ${ALL_CXX_SOURCE_FILES} )
    
    add_custom_target(
        ClangTidy
        COMMAND ${Python3_EXECUTABLE} ${RUN_CLANG_TIDY} ${RUN_CLANG_TIDY_BIN_ARGS}
        COMMENT "running clang tidy"
        WORKING_DIR "${CMAKE_SOURCE_DIR}")
  else()
    list(APPEND CLANG_TIDY_BIN_ARGS
         -p=${CMAKE_BINARY_DIR}
         -quiet
         -header-filter=.*           #"\"-header-filter=.*(apps|GameLib|source).*\""
         -format-style=file
         --extra-arg=\"-std=c++17\"
         ${ALL_CXX_SOURCE_FILES} )
    
    add_custom_target(
        Tidy
        COMMAND ${CLANG_TIDY} ${CLANG_TIDY_BIN_ARGS}
        COMMENT "running clang tidy" )
  endif()
else()
  message("Clang-Tidy could not be located. Static analysis failed")
  return()
endif()