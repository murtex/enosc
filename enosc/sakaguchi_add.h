/**
 * sakaguchi_add.h
 * 20160309
 *
 * additive sakaguchi ensemble
 */
#ifndef ENOSC_SAKAGUCHI_ADD_H
#define ENOSC_SAKAGUCHI_ADD_H

	/* includes */
#include <enosc/ensemble.h>

	/* interface */
namespace enosc
{

		/* ensemble */
	class SakaguchiAdd : public enosc::Ensemble
	{

			/* con/destruction */
		public:

			SakaguchiAdd();
			~SakaguchiAdd() {}

			/* configuration */
		protected:

			double _gamma; /* noise strength */

		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* phase space */
		public:

			void init();

			/* ode */
		public:

			bool compute_deriv_det( enosc::device_vector const & state, enosc::scalar time );
			bool compute_deriv_stoch( enosc::device_vector const & state, enosc::scalar time );

	};

		/* ode */
	struct SakaguchiAddDetODE
	{
		enosc::scalar gamma;

		SakaguchiAddDetODE( enosc::scalar gamma )
			: gamma( gamma ) {}

		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const A = thrust::get< 0 >( t ); /* state input */
			enosc::scalar const phi = thrust::get< 1 >( t );

            enosc::scalar const epsilon = thrust::get< 2 >( t ); /* coupling input */
			enosc::scalar const beta = thrust::get< 3 >( t );

            enosc::scalar const K = thrust::get< 4 >( t ); /* meanfield input */
			enosc::scalar const theta = thrust::get< 5 >( t );

			thrust::get< 6 >( t ) = 0; /* derivative output */
			thrust::get< 7 >( t ) = 1 + epsilon*K*sin( theta - phi + beta*M_PI );
		}
	};

	struct SakaguchiAddStochODE
	{
		enosc::scalar gamma;

		SakaguchiAddStochODE( enosc::scalar gamma )
			: gamma( gamma ) {}

		template< typename T >
		__host__ __device__
		void operator()( T t )
		{
			enosc::scalar const A = thrust::get< 0 >( t ); /* state input */
			enosc::scalar const phi = thrust::get< 1 >( t );

            enosc::scalar const epsilon = thrust::get< 2 >( t ); /* coupling input */
			enosc::scalar const beta = thrust::get< 3 >( t );

            enosc::scalar const K = thrust::get< 4 >( t ); /* meanfield input */
			enosc::scalar const theta = thrust::get< 5 >( t );

			thrust::get< 6 >( t ) = 0; /* derivative output */
			thrust::get< 7 >( t ) = sqrt( 2*gamma );
		}
	};

}

#endif /* ENOSC_SAKAGUCHI_ADD_H */

