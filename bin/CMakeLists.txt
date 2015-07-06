cuda_add_executable( integrate
	integrate.cu )
target_link_libraries( integrate
	config++
	xis
	enosc )

