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
			virtual ~Roessler() {}

			/* configuration */
		protected:

			double _a; /* roessler parameters */
			double _b;
			double _c;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			/* phase space */
		public:

			virtual void init( unsigned int seed );

	};

}

#endif /* ENOSC_ROESSLER_H */

