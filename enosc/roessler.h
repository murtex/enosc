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

			void init( unsigned int seed, bool det, bool stoch );

			/* computation */
		public:

			enosc::device_vector const & compute_deriv_det( enosc::device_vector const & state, enosc::scalar time );
			enosc::device_vector const & compute_deriv_stoch( enosc::device_vector const & state, enosc::scalar time ) { return _deriv_stoch; }

	};

}

#endif /* ENOSC_ROESSLER_H */

