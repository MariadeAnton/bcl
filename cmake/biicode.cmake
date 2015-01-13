#=============================================================================#
#                                                                             #
#         				  biicode.cmake    									  #
#                                                                             #
#=============================================================================#
# This file contains all the macros and functions that make possible to create
# the targets (executables, libraries, etc) and respect the user project
# configuration and/or CMakeLists.txt files


#=============================================================================#
#				General SET and INCLUDE_DIRECTORIES
#=============================================================================#

# Defining variables to save the created binary files
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/../bin)
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_HOME_DIRECTORY}/../bin)

# Including /blocks and /deps directories
INCLUDE_DIRECTORIES(${CMAKE_HOME_DIRECTORY}/../blocks)
INCLUDE_DIRECTORIES(${CMAKE_HOME_DIRECTORY}/../deps)

# The BIICODE variable is used to execute (or not) some wished parts of any user
# block CMakeLists. For example:
# 		IF(NOT BIICODE)
#			ADD_SUBDIRECTORY(util)
# 		ENDIF()
SET(BIICODE TRUE)

#=============================================================================#
#
#						PUBLIC FUNCTIONS AND MACROS
#
#=============================================================================#

#=============================================================================#
# [PUBLIC/USER] [USER BLOCK CMAKELISTS]
#
# INIT_BIICODE_BLOCK()
#
# Loads bii_user_block_vars.cmake files located in cmake directory
# This macro must be called by the root CMakeLists.txt of a block
# at the beginning, after the biicode.cmake inclusion.
#
#=============================================================================#

macro(INIT_BIICODE_BLOCK)
	CREATE_BII_BLOCK_VARS(${CMAKE_CURRENT_SOURCE_DIR})
	SET(vname "${BII_BLOCK_USER}_${BII_BLOCK_NAME}")
	# Load vars.cmake file with variables
	SET(var_file_name "bii_${vname}_vars.cmake")
	INCLUDE(${CMAKE_HOME_DIRECTORY}/${var_file_name})
	MESSAGE("\n\t\tBLOCK: ${BII_BLOCK_USER}/${BII_BLOCK_NAME} ")
	MESSAGE("-----------------------------------------------------------")

	# Flag to inform that the block has been initiated
	SET(BII_${vname}_INITIATED TRUE CACHE INTERNAL "biicode")
	SET(BII_${vname}_FINISHED FALSE CACHE INTERNAL "biicode")
endmacro() 

#=============================================================================#
# [PUBLIC/USER] [USER BLOCK CMAKELISTS]
#
# ADD_BIICODE_TARGETS()
#
#
# Adds and selects the target to be created. It's in charge of calling the macros
# which generate a library or a executable file.
#
#=============================================================================#

macro(ADD_BIICODE_TARGETS)
	set(BII_BLOCK_TARGETS)
	SET(BII_BLOCK_TARGET "${BII_BLOCK_USER}_${BII_BLOCK_NAME}_interface") 
	# LIBRARY
	SET(vname "${BII_BLOCK_USER}_${BII_BLOCK_NAME}") 
	MESSAGE("+ ${BII_LIB_TYPE} LIB: ${vname}")
	BII_GENERATE_LIB(${BII_BLOCK_USER} ${BII_BLOCK_NAME})
	
	set(BII_BLOCK_TARGETS ${BII_BLOCK_TARGETS} "${vname}")
	set(BII_LIB_TARGET "${vname}")

	# EXECUTABLES
	foreach(executable ${BII_BLOCK_EXES} )
		set(BII_${executable}_TARGET "${BII_BLOCK_USER}_${BII_BLOCK_NAME}_${executable}")
		MESSAGE("+ EXE: ${BII_${executable}_TARGET}")
		BII_GENERATE_EXECUTABLE( ${BII_BLOCK_USER} ${BII_BLOCK_NAME} ${executable})
		SET(BII_BLOCK_TARGETS ${BII_BLOCK_TARGETS} "${BII_BLOCK_USER}_${BII_BLOCK_NAME}_${executable}")
	endforeach ()
	SET(BII_${vname}_FINISHED TRUE CACHE INTERNAL "biicode")
endmacro()


#=============================================================================#
# [PUBLIC/USER] [USER BLOCK CMAKELISTS]
#
# BII_CONFIGURE_FILE(config_file_in config_file_out)
#
#        config_file_in    - Existing configure file name to charge
#		 config_file_out   - Output file where will be copied all the necessary
#
# Avoids errors due to the layout of configure. IT SHOULD be used instead of
# configure_file.
#
#=============================================================================#

macro (BII_CONFIGURE_FILE config_file_in config_file_out)
	configure_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/${config_file_in}"
	"${CMAKE_CURRENT_BINARY_DIR}/${config_file_out}"
	)
endmacro()


#=============================================================================#
# [PUBLIC/USER] [USER BLOCK CMAKELISTS]
#
# BII_FILTER_LIB_SRC(ACCEPTABLE_SOURCES)
#
#        ACCEPTABLE_SOURCES    - List of sources to preserve
#
# Removes from biicode SRC list of calculated sources if not present in
# ACCEPTABLE_SOURCES.
#
#=============================================================================#

macro (BII_FILTER_LIB_SRC ACCEPTABLE_SOURCES)
	set(FILES_TO_REMOVE )
	foreach(_cell ${BII_LIB_SRC})
	  list(FIND ${ACCEPTABLE_SOURCES} ${_cell} contains)
	  if(contains EQUAL  -1)
		list(APPEND FILES_TO_REMOVE ${_cell})
	  endif(contains) 
	endforeach()

	IF(FILES_TO_REMOVE)
		list(REMOVE_ITEM BII_LIB_SRC ${FILES_TO_REMOVE})
	ENDIF()
endmacro()


#=============================================================================#
# [PUBLIC/USER] [USER BLOCK CMAKELISTS]
#
# DISABLE_BII_IMPLICIT_RULES()
#
#
# Disables the BII_IMPLICIT_RULES_ENABLED (True by default) to link all our targets 
#
#=============================================================================#

macro(DISABLE_BII_IMPLICIT_RULES)
	unset(BII_IMPLICIT_RULES_ENABLED)
endmacro(DISABLE_BII_IMPLICIT_RULES)


#=============================================================================#
# [PUBLIC/USER] [MAIN BIICODE CMAKELISTS]
#
# BII_INCLUDE_BLOCK(BLOCK_DIR)
#
#        BLOCK_DIR    - Relative path to block, f.e.: blocks/myuser/simple_block
#
#
# Used by the root CMakeLists.txt.
#
# Initialize the necessary user block variables and validates the specific
# CMakeLists.txt.
#
# If this last one doesn't exist, biicode creates a default CMakLists.txt in
# that block
#
#=============================================================================#

macro(BII_INCLUDE_BLOCK BLOCK_DIR)
	get_filename_component(bii_hive_dir ${CMAKE_HOME_DIRECTORY} PATH)
	CREATE_BII_BLOCK_VARS( ${bii_hive_dir}/${BLOCK_DIR})

	# Deletes the oldest cached CMakeLists path 
	unset(_CMAKELISTPATH CACHE)

	# Copies the path to block CMakeLists file (if exists)
	file(TO_NATIVE_PATH "../${BLOCK_DIR}/CMakeLists.txt" _CMAKELISTPATH)

	if(NOT EXISTS ${_CMAKELISTPATH})
		message(ERROR, "ERROR, MISSING CMAKELISTS at: ${_CMAKELISTPATH}")
	else()
		ADD_SUBDIRECTORY("../${BLOCK_DIR}" "../build/${BII_BLOCK_USER}/${BII_BLOCK_NAME}")
		VALIDATE_BLOCK_CMAKELIST("../${BLOCK_DIR}")
	endif()
endmacro()


#=============================================================================#
# [PUBLIC/USER] [MAIN BIICODE CMAKELISTS]
#
# BII_PREBUILD_STEP(path)
#
#        path    - Relative path to block, f.e. : blocks/myuser/simple_block
#
# Called by the biicode main CMakeLists.txt, processes the biicode.configure 
# file if exists. Does nothing other case.
#
#=============================================================================#

function(BII_PREBUILD_STEP block_path)
	# Convenience per block Interface target
	get_filename_component(_bii_block_name ${block_path} NAME)
	get_filename_component(_aux ${block_path} PATH)
	get_filename_component(_bii_user_name ${_aux} NAME)
	SET(BII_BLOCK_TARGET "${_bii_user_name}_${_bii_block_name}_interface") 
	ADD_LIBRARY(${BII_BLOCK_TARGET} INTERFACE)
	if(EXISTS "${CMAKE_HOME_DIRECTORY}/../${block_path}/bii_deps_config.cmake")
		include("${CMAKE_HOME_DIRECTORY}/../${block_path}/bii_deps_config.cmake")
	endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# BII_SET_OPTION(name)
#
#        name    - Option name to save
#
# Saves in cache the passed option names 
#
#=============================================================================#

function (BII_SET_OPTION name)
	set(${name} ON CACHE BOOL "biicode" FORCE)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# BII_UNSET_OPTION(name)
#
#        name    - Option name to delete from cache
#
# Deletes from cache the passed option names 
#
#=============================================================================#


function (BII_UNSET_OPTION name)
	set(${name} OFF CACHE BOOL "biicode" FORCE)
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# CREATE_BII_BLOCK_VARS(BII_CURRENT_DIR)
#
#
#        BII_CURRENT_DIR    - Relative path to the root CMakeLists.txt the block
#                             folder, f.e.: ../blocks/myuser/myblock
#
# Gets the user block and prefix from path.
#
#=============================================================================#

macro (CREATE_BII_BLOCK_VARS BII_CURRENT_DIR)
	unset(vname CACHE)
	unset(BII_BLOCK_NAME CACHE)
	unset(BII_BLOCK_USER CACHE)
	unset(BLOCK_DIR CACHE)
	get_filename_component(bii_user_dir ${BII_CURRENT_DIR} PATH)
	get_filename_component(bii_base_dir ${bii_user_dir} PATH)
	get_filename_component(bii_hive_dir ${CMAKE_HOME_DIRECTORY} PATH)
	get_filename_component(BII_BLOCK_NAME ${BII_CURRENT_DIR} NAME)
	get_filename_component(BII_BLOCK_USER ${bii_user_dir} NAME)
	get_filename_component(BII_BLOCK_PREFIX ${bii_base_dir} NAME)
    SET(BII_IMPLICIT_RULES_ENABLED True)
endmacro ()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# VALIDATE_BLOCK_CMAKELIST(BII_DIR)
#
#        BII_DIR    - Relative path to the root CMakeLists.txt the block folder,
#					  f.e.: ../blocks/myuser/myblock
#
# Validates the possible CMakeLists.txt from user block folder.
#
#=============================================================================#

function(VALIDATE_BLOCK_CMAKELIST BII_DIR)
	CREATE_BII_BLOCK_VARS( ${BII_DIR})
	SET(vname "${BII_BLOCK_USER}_${BII_BLOCK_NAME}")
	message(AUTHOR_WARNING "check: BII_${vname}_INITIATED: ${BII_${vname}_INITIATED}\n")
	message(AUTHOR_WARNING "check: BII_${vname}_FINISHED: ${BII_${vname}_FINISHED}\n")

	# Checking INIT_BIICODE_BLOCK() is saved in the CMakLists.txt
	if(NOT BII_${vname}_INITIATED)
		message(SEND_ERROR "INIT_BIICODE_BLOCK() not found into the Cmakelist of ${vname}.
	****************************************************************************
	The root Cmakelist of a block must include INIT_BIICODE_BLOCK & 
	ADD_BIICODE_TARGETS. Please check the documentation about 
	CMakelist.txt at www.biicode.com
	****************************************************************************
	") 
	endif()

	# Checking ADD_BIICODE_TARGETS() is saved in the CMakLists.txt
	if(NOT BII_${vname}_FINISHED)
		message(SEND_ERROR "ADD_BIICODE_TARGETS() not found in the Cmakelist of ${vname}.\n
		 Please, add that line to your CMakelist") 
	endif()
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# BII_GENERATE_EXECUTABLE(USER BLOCK FNAME)
#
#        USER    - User name
#        BLOCK   - Block folder name
#        FNAME   - Main file name 
#
# Creates the binary  target name. It's in charge of setting the necessary
# properties to the target and linking with the libraries that target depends on.
#
# It can create the C/C++ and Arduino binary target files.
#
#=============================================================================#

function(BII_GENERATE_EXECUTABLE USER BLOCK FNAME)
	SET(vname "${USER}_${BLOCK}_${FNAME}")
	SET(aux_src ${BII_${FNAME}_SRC})

    ADD_EXECUTABLE( ${vname} ${aux_src})
    SET(interface_target "${BII_BLOCK_USER}_${BII_BLOCK_NAME}_interface")
    if(BII_${FNAME}_DEPS)
        TARGET_LINK_LIBRARIES( ${vname} PUBLIC ${BII_${FNAME}_DEPS})
    endif()
    if(BII_${FNAME}_INCLUDE_PATHS)
        target_include_directories( ${vname} PUBLIC ${BII_${FNAME}_INCLUDE_PATHS})
    endif()
    TARGET_LINK_LIBRARIES( ${vname} PUBLIC ${interface_target})

    if(BII_${FNAME}_SYSTEM_HEADERS)
        HANDLE_SYSTEM_DEPS(${vname} PUBLIC "BII_${FNAME}_SYSTEM_HEADERS")
    endif()

endfunction() 


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# BII_GENERATE_LIB(USER BLOCK)
#
#        USER    - User name
#        BLOCK   - Block folder name 
#
# Creates the library with the biicode target name. It's in charge of setting 
# the necessary properties to the target and linking with other libraries that
# target depends on.
#
# It can create the C/C++ and Arduino library target files. The libraries'll
# be STATIC by default.
#
#=============================================================================#

function(BII_GENERATE_LIB USER BLOCK)
	SET(vname "${USER}_${BLOCK}") 
	if(BII_LIB_SRC)
	  #get_filename_component(parent_dir ${CMAKE_HOME_DIRECTORY} PATH)
	  #SET(DUMMY_DIR "${parent_dir}/build/${USER}/${BLOCK}")
	  SET(DUMMY_SRC "${CMAKE_CURRENT_BINARY_DIR}/cmake_dummy.cpp")
	  IF (NOT EXISTS ${DUMMY_SRC})
	          MESSAGE(STATUS "Writing default cmake_dummy.cpp for building library")
	          FILE (WRITE  ${DUMMY_SRC} "//a dummy file for building header only libs with CMake 2.8")
	  ENDIF()
  	  SET(aux_src ${BII_LIB_SRC} ${DUMMY_SRC})
  	endif()

    if(BII_LIB_SRC)
        add_library(${vname} ${BII_LIB_TYPE} ${aux_src})
    else()
        add_library(${vname} INTERFACE)
    endif()

    SET(interface_target "${BII_BLOCK_USER}_${BII_BLOCK_NAME}_interface")
    set(aux_deps ${BII_LIB_DEPS} ${interface_target})
    if(aux_deps)
        foreach( aux_dep ${aux_deps})
            if(BII_LIB_SRC)
                TARGET_LINK_LIBRARIES( ${vname} PUBLIC ${aux_dep})
            else()
                TARGET_LINK_LIBRARIES( ${vname} INTERFACE ${aux_dep})
            endif()
        endforeach()
    endif()
    if(BII_LIB_INCLUDE_PATHS)
        if(BII_LIB_SRC)
            target_include_directories( ${vname} PUBLIC ${BII_LIB_INCLUDE_PATHS})
        else()
            target_include_directories( ${vname} INTERFACE ${BII_LIB_INCLUDE_PATHS})
        endif()
    endif()
    if(BII_LIB_SYSTEM_HEADERS)
        if(BII_LIB_SRC)
            HANDLE_SYSTEM_DEPS(${vname} PUBLIC "BII_LIB_SYSTEM_HEADERS")
        else()
            HANDLE_SYSTEM_DEPS(${vname} INTERFACE "BII_LIB_SYSTEM_HEADERS")
        endif()
    endif()

endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# HANDLE_SYSTEM_DEPS(target_name sys_deps)
#
#        target_name    - Complete target name, f.e.: myuser_myblock_main
#        sys_deps       - System dependencies detected by biicode 
#
# Links the passed targets with the selected system dependencies
#
#=============================================================================#

function(HANDLE_SYSTEM_DEPS target_name ACCESS sys_deps)
	if(${BII_IMPLICIT_RULES_ENABLED})
		foreach(sys_dep ${${sys_deps}})
			if(${sys_dep} STREQUAL "math.h")
				if(UNIX)
					target_link_libraries(${target_name} ${ACCESS} "m")
				endif()
			elseif((${sys_dep} STREQUAL "pthread.h") OR (${sys_dep} STREQUAL "thread"))
				if(UNIX)
					target_link_libraries(${target_name} ${ACCESS} "pthread")
				endif()
			elseif(${sys_dep} STREQUAL "GL/gl.h")
				if(APPLE)
					FIND_LIBRARY(OpenGL_LIBRARY OpenGL)
					target_link_libraries(${target_name} ${ACCESS} ${OpenGL_LIBRARY})
				elseif(UNIX)
					target_link_libraries(${target_name} ${ACCESS} "GL")
				elseif(WIN32)
					target_link_libraries(${target_name} ${ACCESS} "opengl32")
				endif()
			elseif(${sys_dep} STREQUAL "GL/glu.h")
				if(UNIX)
					if(APPLE)
						FIND_PACKAGE(GLU REQUIRED)
						TARGET_LINK_LIBRARIES(${target_name} ${ACCESS} ${GLU_LIBRARY})
					else()
						target_link_libraries(${target_name} ${ACCESS} "GLU")
					endif()
				elseif(WIN32)
					target_link_libraries(${target_name} ${ACCESS} "glu32")
				endif()
			elseif(${sys_dep} STREQUAL "winsock2.h")
				if(WIN32)
					target_link_libraries(${target_name} ${ACCESS} "ws2_32")
				endif()
			elseif(${sys_dep} STREQUAL "mmsystem.h")
				if(WIN32)
					target_link_libraries(${target_name} ${ACCESS} "winmm")
				endif()
			endif()
		endforeach()
	endif()

endfunction()


