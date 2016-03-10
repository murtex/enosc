/**
 * roessler_mod.h
 * 20150727
 *
 * modified roessler ensemble
 */
#ifndef ENOSC_ROESSLER_MOD_H
#define ENOSC_ROESSLER_MOD_H

	/* includes */
#include <enosc/ensemble.h>

	/* interface */
namespace enosc
{

		/* ensemble */
	class RoesslerMod : public enosc::Ensemble
	{

			/* con/destruction */
		public:

			RoesslerMod();
			~RoesslerMod() {}

			/* configuration */
		protected:

			double _e; /* roessler parameters */
			double _f;
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
	struct RoesslerModODE
	{
		enosc::scalar e;
		enosc::scalar f;
		enosc::scalar c;

		RoesslerModODE( enosc::scalar e, enosc::scalar f, enosc::scalar c )
			: e( e ), f( f ), c( c ) {}

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
			enosc::scalar const r2 = x*x + y*y;

			enosc::scalar const sak_real = mx*cosbeta - my*sinbeta;
			enosc::scalar const sak_imag = mx*sinbeta + my*cosbeta;

			thrust::get< 7 >( t ) = e/2*x - y - z*x*x/r2 + epsilon*sak_real;
			thrust::get< 8 >( t ) = e/2*y + x - z*x*y/r2 + epsilon*sak_imag;
            thrust::get< 9 >( t ) = f + z*(x - c);
		}
	};

}

#endif /* ENOSC_ROESSLER_MOD_H */

