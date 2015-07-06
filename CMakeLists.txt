cmake_minimum_required( VERSION 3.2 )
project( enosc )

	# c/c++ settings
set( CMAKE_VERBOSE_MAKEFILE FALSE )

set( CMAKE_BUILD_TYPE Release )

include_directories( ${CMAKE_SOURCE_DIR} )

#add_compile_options( "-std=c++11" )
list( APPEND CMAKE_CXX_FLAGS "-Wall" ) # must set any cxx flag, separable cuda compilation gives error otherwise!

	# cuda settings
find_package( CUDA REQUIRED )

set( CUDA_VERBOSE_BUILD OFF )

set( CUDA_SEPARABLE_COMPILATION ON )

list( APPEND CUDA_NVCC_FLAGS "-arch=sm_30" ) # cannot use c++11, https://bugs.archlinux.org/task/45079

	# targets
add_subdirectory( xis )
add_subdirectory( enosc )
add_subdirectory( bin )

