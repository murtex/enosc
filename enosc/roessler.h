/**
 * roessler.h
 * 20150703
 *
 * roessler ensemble
 */
#ifndef ENOSC_ROESSLER_H
#define ENOSC_ROESSLER_H

	/* includes */
#include <enosc/ensemble.h>

	/* interface */
namespace enosc
{

		/* ensemble */
	class Roessler : public enosc::Ensemble
	{

			/* con/destruction */
		public:

			Roessler();
			~Roessler() {}

			/* configuration */
		protected:

			double _a; /* roessler parameters */
			double _b;
			double _c;

		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* phase space */
		public:

			void init();

			/* ode */
		public:

			bool compute_deriv_det( enosc::device_vector const & state, enosc::scalar time );

	};

		/* ode */
	struct RoesslerODE
	{
		enosc::scalar a;
		enosc::scalar b;
		enosc::scalar c;

		RoesslerODE( enosc::scalar a, enosc::scalar b, enosc::scalar c )
			: a( a ), b( b ), c( c ) {}

		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const x = thrust::get< 0 >( t ); /* state input */
			enosc::scalar const y = thrust::get< 1 >( t );
			enosc::scalar const z = thrust::get< 2 >( t );

            enosc::scalar const epsilon = thrust::get< 3 >( t ); /* coupling input */
			enosc::scalar const beta = thrust::get< 4 >( t );

            enosc::scalar const mx = thrust::get< 5 >( t ); /* meanfield input */
			enosc::scalar const my = thrust::get< 6 >( t );

			enosc::scalar const sinbeta = sin( beta * M_PI ); /* pre-computations */
			enosc::scalar const cosbeta = cos( beta * M_PI );

			enosc::scalar const sak_real = mx*cosbeta - my*sinbeta;
			enosc::scalar const sak_imag = mx*sinbeta + my*cosbeta;

			thrust::get< 7 >( t ) = -y - z + epsilon*sak_real; /* derivative output */
			thrust::get< 8 >( t ) = x + a*y + epsilon*sak_imag;
            thrust::get< 9 >( t ) = b + z*(x - c);
		}
	};

}

#endif /* ENOSC_ROESSLER_H */

