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

	struct PolarToCartesianFull
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const r = thrust::get< 0 >( t ); /* polar input */
			enosc::scalar const phi = thrust::get< 1 >( t );
			enosc::scalar const drdt = thrust::get< 2 >( t );
			enosc::scalar const dphidt = thrust::get< 3 >( t );

			enosc::scalar const sinphi = sin( phi ); /* pre-computatios */
			enosc::scalar const cosphi = cos( phi );
			enosc::scalar const rdphidt = r*dphidt;

			thrust::get< 4 >( t ) = r*cosphi; /* cartesian output */
			thrust::get< 5 >( t ) = r*sinphi;
			thrust::get< 6 >( t ) = drdt*cosphi - rdphidt*sinphi; /* dx/dt */
			thrust::get< 7 >( t ) = drdt*sinphi + rdphidt*cosphi; /* dy/dt */
		}
	};

	struct PolarToPolarFull
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			thrust::get< 4 >( t ) = thrust::get< 0 >( t ); /* indentity */
			thrust::get< 5 >( t ) = thrust::get< 1 >( t );
			thrust::get< 6 >( t ) = thrust::get< 2 >( t );
			thrust::get< 7 >( t ) = thrust::get< 3 >( t );
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

	struct CartesianToPolarFull
	{
		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const x = thrust::get< 0 >( t ); /* cartesian input */
			enosc::scalar const y = thrust::get< 1 >( t );
			enosc::scalar const dxdt = thrust::get< 2 >( t );
			enosc::scalar const dydt = thrust::get< 3 >( t );

			enosc::scalar const r2 = x*x + y*y; /* pre-computatios */
			enosc::scalar const r = sqrt( r2 );
			enosc::scalar phi = atan2( y, x );
			if ( phi < 0 )
				phi += 2*M_PI; /* [0, 2pi) */

			thrust::get< 4 >( t ) = r; /* polar output */
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

