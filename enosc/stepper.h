/**
 * stepper.h
 * 20150706
 *
 * stepper interface
 */
#ifndef ENOSC_STEPPER_H
#define ENOSC_STEPPER_H

	/* includes */
#include <xis/config.h>

#include <enosc/types.h>
#include <enosc/ensemble.h>

	/* interface */
namespace enosc
{

		/* stepper */
	class Stepper : public xis::Config
	{

			/* con/destruction */
		public:

			Stepper();
			virtual ~Stepper() {}

			/* configuration */
		protected:

			enosc::host_vector _times; /* integration steps */
			enosc::scalar _dt;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			enosc::host_vector const & get_times() { return _times; }
			enosc::scalar get_dt() { return _dt; }

			/* integration */
		public:

			virtual void integrate( enosc::Ensemble & ensemble, unsigned int step ) = 0;

	};

}

#endif /* ENOSC_STEPPER_H */

