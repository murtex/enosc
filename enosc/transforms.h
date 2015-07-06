/**
 * transforms.h
 * 20150705
 *
 * transform kernels
 */
#ifndef ENOSC_TRANSFORMS_H
#define ENOSC_TRANSFORMS_H

	/* includes */
#include <enosc/types.h>

	/* interface */
namespace enosc
{

		/* kernels */
	struct PolarToCartesian
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const r = thrust::get< 0 >( t ); /* polar input */
			enosc::scalar const phi = thrust::get< 1 >( t );

			thrust::get< 2 >( t ) = r * cos( phi ); /* cartesian output */
			thrust::get< 3 >( t ) = r * sin( phi );
		}
	};

	struct CylinderToCartesian
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const r = thrust::get< 0 >( t ); /* cylinder input */
			enosc::scalar const phi = thrust::get< 1 >( t );

			thrust::get< 3 >( t ) = r * cos( phi ); /* cartesian output */
			thrust::get< 4 >( t ) = r * sin( phi );
			thrust::get< 5 >( t ) = thrust::get< 2 >( t );
		}
	};

}

#endif /* ENOSC_TRANSFORMS_H */

