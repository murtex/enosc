cuda_add_library( enosc
	types.cu
	ensemble.cu	roessler.cu roessler_mod.cu roessler_mod2.cu
	stepper.cu euler.cu
	observer.cu	hdf5.cu )
	
