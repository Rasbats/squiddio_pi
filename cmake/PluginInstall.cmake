##---------------------------------------------------------------------------
## Author:      Pavel Kalian (Based on the work of Sean D'Epagnier)
## Copyright:   2014
## License:     GPLv3+
##---------------------------------------------------------------------------

# Do not run this file if it is a flatpak build
IF(OCPN_FLATPAK)
   return()
ENDIF(OCPN_FLATPAK)


IF(NOT APPLE)
  TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${wxWidgets_LIBRARIES} ${EXTRA_LIBS} )
ENDIF(NOT APPLE)

IF(WIN32)
  SET(PARENT "opencpn")

  IF(MSVC)
#    TARGET_LINK_LIBRARIES(${PACKAGE_NAME}
#	gdiplus.lib
#	glu32.lib)
    TARGET_LINK_LIBRARIES(${PACKAGE_NAME} ${OPENGL_LIBRARIES})

    SET(OPENCPN_IMPORT_LIB "${CMAKE_SOURCE_DIR}/api-16/opencpn.lib")
  ENDIF(MSVC)

  IF(MINGW)
# assuming wxwidgets is compiled with unicode, this is needed for mingw headers
    ADD_DEFINITIONS( " -DUNICODE" )
    TARGET_LINK_LIBRARIES(${PACKAGE_NAME} ${OPENGL_LIBRARIES})
    SET(OPENCPN_IMPORT_LIB "${CMAKE_SOURCE_DIR}/api-16/libopencpn.dll.a")
  ENDIF(MINGW)

  TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${OPENCPN_IMPORT_LIB} )
ENDIF(WIN32)

IF(UNIX)
 IF(PROFILING)
  find_library(GCOV_LIBRARY
    NAMES
    gcov
    PATHS
    /usr/lib/gcc/i686-pc-linux-gnu/4.7
    )

  SET(EXTRA_LIBS ${EXTRA_LIBS} ${GCOV_LIBRARY})
 ENDIF(PROFILING)
ENDIF(UNIX)

IF(APPLE)
 FIND_PACKAGE(ZLIB REQUIRED)
 TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${ZLIB_LIBRARIES} )
 INSTALL(TARGETS ${PACKAGE_NAME} RUNTIME LIBRARY DESTINATION OpenCPN.app/Contents/PlugIns)
ENDIF(APPLE)

IF(UNIX AND NOT APPLE)
    FIND_PACKAGE(BZip2 REQUIRED)
    INCLUDE_DIRECTORIES(${BZIP2_INCLUDE_DIR})
    FIND_PACKAGE(ZLIB REQUIRED)
    INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR})
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${BZIP2_LIBRARIES} ${ZLIB_LIBRARY} )
ENDIF(UNIX AND NOT APPLE)

SET(PARENT opencpn)

SET(PREFIX_DATA share)
SET(PREFIX_LIB lib)

IF(WIN32)
    MESSAGE (STATUS "Install Prefix: ${CMAKE_INSTALL_PREFIX}")
    SET(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/../OpenCPN)
  IF(CMAKE_CROSSCOMPILING)
    INSTALL(TARGETS ${PACKAGE_NAME} RUNTIME DESTINATION "plugins")
    SET(INSTALL_DIRECTORY "plugins/${PACKAGE_NAME}")
  ELSE(CMAKE_CROSSCOMPILING)
    INSTALL(TARGETS ${PACKAGE_NAME} RUNTIME DESTINATION "plugins")
    SET(INSTALL_DIRECTORY "plugins\\\\${PACKAGE_NAME}")
  ENDIF(CMAKE_CROSSCOMPILING)

  IF(EXISTS ${PROJECT_SOURCE_DIR}/data)
    INSTALL(DIRECTORY data DESTINATION "${INSTALL_DIRECTORY}")
  ENDIF(EXISTS ${PROJECT_SOURCE_DIR}/data)
ENDIF(WIN32)

IF(UNIX AND NOT APPLE)
  SET(PREFIX_PARENTDATA ${PREFIX_DATA}/${PARENT})
  IF(NOT DEFINED PREFIX_PLUGINS)
    SET(PREFIX_PLUGINS ${PREFIX_LIB}/${PARENT})
  ENDIF(NOT DEFINED PREFIX_PLUGINS)
  INSTALL(TARGETS ${PACKAGE_NAME} RUNTIME LIBRARY DESTINATION ${PREFIX_PLUGINS})

  IF(EXISTS ${PROJECT_SOURCE_DIR}/data)
    INSTALL(DIRECTORY data DESTINATION ${PREFIX_PARENTDATA}/plugins/${PACKAGE_NAME})
  ENDIF()
ENDIF(UNIX AND NOT APPLE)
