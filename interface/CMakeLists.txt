set(TARGET_NAME interface)
project(${TARGET_NAME})

# set a default root dir for each of our optional externals if it was not passed
find_package(Qt5LinguistTools REQUIRED)
find_package(Qt5LinguistToolsMacros)

set(BUILD_SEQ "dev")

if (WIN32)
  add_definitions(-D_USE_MATH_DEFINES) # apparently needed to get M_PI and other defines from cmath/math.h		
  add_definitions(-DWINDOWS_LEAN_AND_MEAN) # needed to make sure windows doesn't go to crazy with its defines		
endif()

configure_file(InterfaceVersion.h.in "${PROJECT_BINARY_DIR}/includes/InterfaceVersion.h")

# grab the implementation and header files from src dirs
file(GLOB_RECURSE INTERFACE_SRCS "src/*.cpp" "src/*.h")
GroupSources("src")

find_package(Qt5 COMPONENTS Gui Multimedia Network OpenGL Qml Quick Script Svg WebKitWidgets)

# add them to the interface source files
set(INTERFACE_SRCS ${INTERFACE_SRCS} "${QT_UI_HEADERS}" "${QT_RESOURCES}")

if (APPLE)
  # configure CMake to use a custom Info.plist
  SET_TARGET_PROPERTIES( ${this_target} PROPERTIES MACOSX_BUNDLE_INFO_PLIST MacOSXBundleInfo.plist.in )

  set(MACOSX_BUNDLE_BUNDLE_NAME Interface)
  set(MACOSX_BUNDLE_GUI_IDENTIFIER io.highfidelity.Interface)
  
  if (UPPER_CMAKE_BUILD_TYPE MATCHES RELEASE OR UPPER_CMAKE_BUILD_TYPE MATCHES RELWITHDEBINFO)
    set(ICON_FILENAME "interface.icns")
  else ()
    set(ICON_FILENAME "interface-beta.icns")
  endif ()
  
  # set how the icon shows up in the Info.plist file
  SET(MACOSX_BUNDLE_ICON_FILE "${ICON_FILENAME}")

  # set where in the bundle to put the resources file
  SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_SOURCE_DIR}/icon/${ICON_FILENAME} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
  
  set(DISCOVERED_RESOURCES "")

  # use the add_resources_to_os_x_bundle macro to recurse into resources
  add_resources_to_os_x_bundle("${CMAKE_CURRENT_SOURCE_DIR}/resources")

  # append the discovered resources to our list of interface sources
  list(APPEND INTERFACE_SRCS ${DISCOVERED_RESOURCES})
  
  set(INTERFACE_SRCS ${INTERFACE_SRCS} "${CMAKE_CURRENT_SOURCE_DIR}/icon/${ICON_FILENAME}")
endif()

# create the executable, make it a bundle on OS X
if (APPLE)
  add_executable(${TARGET_NAME} MACOSX_BUNDLE ${INTERFACE_SRCS} ${QM})
elseif(WIN32)
  add_executable(${TARGET_NAME} WIN32 ${INTERFACE_SRCS} ${QM})
else()
  add_executable(${TARGET_NAME} ${INTERFACE_SRCS} ${QM})
endif()

# link required hifi libraries
#link_hifi_libraries(shared)

# include headers for interface and InterfaceConfig.
include_directories("${PROJECT_SOURCE_DIR}/src" "${PROJECT_BINARY_DIR}/includes")

target_link_libraries(
  ${TARGET_NAME}
  Qt5::Gui Qt5::Network Qt5::Multimedia Qt5::OpenGL Qt5::Script Qt5::Svg Qt5::WebKitWidgets
)

# assume we are using a Qt build without bearer management
add_definitions(-DQT_NO_BEARERMANAGEMENT)

if (APPLE)
  # link in required OS X frameworks and include the right GL headers
  find_library(OpenGL OpenGL)
  find_library(AppKit AppKit)

  target_link_libraries(${TARGET_NAME} ${OpenGL} ${AppKit})
    
  # install command for OS X bundle
  INSTALL(TARGETS ${TARGET_NAME}
    BUNDLE DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/install" COMPONENT Runtime
    RUNTIME DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/install" COMPONENT Runtime
  )
else (APPLE)
  # copy the resources files beside the executable
  add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy_directory
    "${PROJECT_SOURCE_DIR}/resources"
    $<TARGET_FILE_DIR:${TARGET_NAME}>/resources
  )
    
  find_package(OpenGL REQUIRED)
  
  if (${OPENGL_INCLUDE_DIR})
    include_directories(SYSTEM "${OPENGL_INCLUDE_DIR}")
  endif ()
  
  target_link_libraries(${TARGET_NAME} "${OPENGL_LIBRARY}")
endif (APPLE)

copy_dlls_beside_windows_executable()
