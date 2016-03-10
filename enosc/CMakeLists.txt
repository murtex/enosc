cuda_add_library( enosc
	types.cu
	ensemble.cu	roessler.cu roessler_mod.cu sakaguchi.cu sakaguchi_add.cu sakaguchi_mul.cu
	stepper.cu euler.cu heun.cu
	observer.cu	hdf5.cu )
	
