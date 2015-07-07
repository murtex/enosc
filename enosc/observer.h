/**
 * observer.h
 * 20150704
 *
 * observer interface
 */
#ifndef ENOSC_OBSERVER_H
#define ENOSC_OBSERVER_H

	/* includes */
#include <xis/config.h>

#include <enosc/types.h>
#include <enosc/ensemble.h>
#include <enosc/stepper.h>

	/* interface */
namespace enosc
{

		/* observer */
	class Observer : public xis::Config
	{

			/* con/destruction */
		public:

			Observer();
			virtual ~Observer();

			/* configuration */
		protected:

			std::vector< unsigned int > _oscillators; /* observables */
			bool _meanfield;

			bool _raw;
			bool _raw_deriv;

			bool _polar;
			bool _polar_deriv;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			/* observation */
		public:

			virtual void init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename );

			virtual void observe( enosc::Ensemble & ensemble, enosc::scalar time ) = 0;

	};

}

#endif /* ENOSC_OBSERVER_H */

