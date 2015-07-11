cuda_add_executable( integrate
	integrate.cu )
target_link_libraries( integrate
	gomp tbb
	config++ hdf5 hdf5_cpp
	xis	enosc )

