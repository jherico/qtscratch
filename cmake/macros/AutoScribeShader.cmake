# 
#  AutoScribeShader.cmake
# 
#  Created by Sam Gateau on 12/17/14.
#  Copyright 2014 High Fidelity, Inc.
#
#  Distributed under the Apache License, Version 2.0.
#  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
# 

function(AUTOSCRIBE_SHADER SHADER_FILE)
    
    # Grab include files
    foreach(includeFile  ${ARGN})
        list(APPEND SHADER_INCLUDE_FILES ${includeFile})
    endforeach()

    foreach(SHADER_INCLUDE ${SHADER_INCLUDE_FILES})
        get_filename_component(INCLUDE_DIR ${SHADER_INCLUDE} PATH)
        list(APPEND SHADER_INCLUDES_PATHS ${INCLUDE_DIR})
    endforeach()


    #Extract the unique include shader paths
    set(INCLUDES ${HIFI_LIBRARIES_SHADER_INCLUDE_FILES})
	#message(Hifi for includes ${INCLUDES})
	foreach(EXTRA_SHADER_INCLUDE ${INCLUDES})
      list(APPEND SHADER_INCLUDES_PATHS ${EXTRA_SHADER_INCLUDE})
    endforeach()

    list(REMOVE_DUPLICATES SHADER_INCLUDES_PATHS)
	#message(ready for includes ${SHADER_INCLUDES_PATHS})

    # make the scribe include arguments
    set(SCRIBE_INCLUDES)
    foreach(INCLUDE_PATH ${SHADER_INCLUDES_PATHS})
        set(SCRIBE_INCLUDES ${SCRIBE_INCLUDES} -I ${INCLUDE_PATH}/)
    endforeach()

    # Define the final name of the generated shader file
    get_filename_component(SHADER_TARGET ${SHADER_FILE} NAME_WE)
    get_filename_component(SHADER_EXT ${SHADER_FILE} EXT)
    if(SHADER_EXT STREQUAL .slv)
        set(SHADER_TARGET ${SHADER_TARGET}_vert.h)
    elseif(${SHADER_EXT} STREQUAL .slf) 
        set(SHADER_TARGET ${SHADER_TARGET}_frag.h)
    endif()

    # Target dependant Custom rule on the SHADER_FILE
    if (APPLE)
        set(GLPROFILE MAC_GL)
        set(SCRIBE_ARGS -c++ -D GLPROFILE ${GLPROFILE} ${SCRIBE_INCLUDES} -o ${SHADER_TARGET} ${SHADER_FILE})

        add_custom_command(OUTPUT ${SHADER_TARGET} COMMAND scribe ${SCRIBE_ARGS} DEPENDS scribe ${SHADER_INCLUDE_FILES} ${SHADER_FILE})
    elseif (UNIX)
        set(GLPROFILE LINUX_GL)
        set(SCRIBE_ARGS -c++ -D GLPROFILE ${GLPROFILE} ${SCRIBE_INCLUDES} -o ${SHADER_TARGET} ${SHADER_FILE})

        add_custom_command(OUTPUT ${SHADER_TARGET} COMMAND scribe ${SCRIBE_ARGS} DEPENDS scribe ${SHADER_INCLUDE_FILES} ${SHADER_FILE})
    else (APPLE)
        set(GLPROFILE PC_GL)
        set(SCRIBE_ARGS -c++ -D GLPROFILE ${GLPROFILE} ${SCRIBE_INCLUDES} -o ${SHADER_TARGET} ${SHADER_FILE})

        add_custom_command(OUTPUT ${SHADER_TARGET} COMMAND scribe ${SCRIBE_ARGS} DEPENDS scribe ${SHADER_INCLUDE_FILES} ${SHADER_FILE})
    endif()

    #output the generated file name
    set(AUTOSCRIBE_SHADER_RETURN ${SHADER_TARGET} PARENT_SCOPE)

    file(GLOB INCLUDE_FILES ${SHADER_TARGET})

endfunction()


macro(AUTOSCRIBE_SHADER_LIB)
  
  file(RELATIVE_PATH RELATIVE_LIBRARY_DIR_PATH ${CMAKE_CURRENT_SOURCE_DIR} "${HIFI_LIBRARY_DIR}")
  foreach(HIFI_LIBRARY ${ARGN})    
    #if (NOT TARGET ${HIFI_LIBRARY})
    #  file(GLOB_RECURSE HIFI_LIBRARIES_SHADER_INCLUDE_FILES ${RELATIVE_LIBRARY_DIR_PATH}/${HIFI_LIBRARY}/src/)
    #endif ()
  
    #file(GLOB_RECURSE HIFI_LIBRARIES_SHADER_INCLUDE_FILES ${HIFI_LIBRARY_DIR}/${HIFI_LIBRARY}/src/*.slh)
    list(APPEND HIFI_LIBRARIES_SHADER_INCLUDE_FILES ${HIFI_LIBRARY_DIR}/${HIFI_LIBRARY}/src)
  endforeach()
  #message(${HIFI_LIBRARIES_SHADER_INCLUDE_FILES})

  file(GLOB_RECURSE SHADER_INCLUDE_FILES src/*.slh)
  file(GLOB_RECURSE SHADER_SOURCE_FILES src/*.slv src/*.slf)

  #message(${SHADER_INCLUDE_FILES})
  foreach(SHADER_FILE ${SHADER_SOURCE_FILES})
      AUTOSCRIBE_SHADER(${SHADER_FILE} ${SHADER_INCLUDE_FILES})
      list(APPEND AUTOSCRIBE_SHADER_SRC ${AUTOSCRIBE_SHADER_RETURN})
  endforeach()
  #message(${AUTOSCRIBE_SHADER_SRC})

  if (WIN32)
    source_group("Shaders" FILES ${SHADER_INCLUDE_FILES})
    source_group("Shaders" FILES ${SHADER_SOURCE_FILES})
    source_group("Shaders" FILES ${AUTOSCRIBE_SHADER_SRC})
  endif()

  list(APPEND AUTOSCRIBE_SHADER_LIB_SRC ${SHADER_INCLUDE_FILES})
  list(APPEND AUTOSCRIBE_SHADER_LIB_SRC ${SHADER_SOURCE_FILES})
  list(APPEND AUTOSCRIBE_SHADER_LIB_SRC ${AUTOSCRIBE_SHADER_SRC})

endmacro()
