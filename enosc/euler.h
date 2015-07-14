/**
 * euler.h
 * 20150706
 *
 * euler stepper
 */
#ifndef ENOSC_EULER_H
#define ENOSC_EULER_H

	/* includes */
#include <enosc/stepper.h>

	/* interface */
namespace enosc
{

		/* stepper */
	class Euler : public enosc::Stepper
	{

			/* con/destruction */
		public:

			Euler() {}
			~Euler() {}

			/* configuration */
		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* integration */
		public:

			void init( enosc::Ensemble const & ensemble );

			void integrate( enosc::Ensemble & ensemble, unsigned int step );

	};

}

#endif /* ENOSC_EULER_H */

