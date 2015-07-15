/**
 * kernels.h
 * 20150705
 *
 * common kernels
 */
#ifndef ENOSC_KERNELS_H
#define ENOSC_KERNELS_H

	/* includes */
#include <enosc/types.h>

	/* interface */
namespace enosc
{

		/* transforms */
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

	struct CartesianToPolar
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const x = thrust::get< 0 >( t ); /* cartesian input */
			enosc::scalar const y = thrust::get< 1 >( t );
			enosc::scalar const dxdt = thrust::get< 2 >( t );
			enosc::scalar const dydt = thrust::get< 3 >( t );

			enosc::scalar const r2 = x*x + y*y; /* polar output */
			enosc::scalar const r = sqrt( r2 );
			enosc::scalar phi = atan2( y, x );
			if ( phi < 0 )
				phi += 2*M_PI; /* [0, 2pi) */

			thrust::get< 4 >( t ) = r;
			thrust::get< 5 >( t ) = phi;
			thrust::get< 6 >( t ) = (x*dxdt + y*dydt) / r; /* dr/dt */
			thrust::get< 7 >( t ) = (x*dydt - y*dxdt) / r2; /* dphi/dt */
		}
	};

		/* other */
	struct IsPositive
	{
		__host__ __device__
		bool operator()( enosc::scalar v )
		{
			return !(v < 0);
		}
	};

	struct SetZero
	{
		__host__ __device__
		enosc::scalar operator()( enosc::scalar v )
		{
			return 0;
		}
	};

}

#endif /* ENOSC_KERNELS_H */

