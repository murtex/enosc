cmake_minimum_required( VERSION 3.2 )
project( enosc )

	# general
set( CMAKE_VERBOSE_MAKEFILE FALSE )
set( CMAKE_BUILD_TYPE Release )

find_package( CUDA REQUIRED )
find_package( HDF5 REQUIRED )

include_directories( ${CUDA_INCLUDE_DIRS} )
include_directories( ${CMAKE_SOURCE_DIR} )

	# c/c++
set( CMAKE_CXX_FLAGS, "${CMAKE_CXX_FLAGS} -std=c++11 -Wall" )

	# cuda
set( CUDA_VERBOSE_BUILD OFF )
set( CUDA_SEPARABLE_COMPILATION ON )

list( APPEND CUDA_NVCC_FLAGS "--std=c++11;-arch=sm_30;-D_MWAITXINTRIN_H_INCLUDED" )

	# targets
add_subdirectory( xis )
add_subdirectory( enosc )
add_subdirectory( bin )

