/**
 * ensemble.h
 * 20150703
 *
 * ensemble interface
 */
#ifndef ENOSC_ENSEMBLE_H
#define ENOSC_ENSEMBLE_H

	/* includes */
#include <xis/config.h>

#include <enosc/types.h>

	/* interface */
namespace enosc
{

		/* ensemble */
	class Ensemble : public xis::Config
	{

			/* con/destruction */
		public:

			Ensemble();
			virtual ~Ensemble() {}

			/* configuration */
		protected:

			unsigned int _size; /* ensemble size */
			unsigned int _dim; /* dimensionality */

			enosc::host_vector _epsilons; /* complex meanfield coupling */
			enosc::host_vector _betas;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			virtual unsigned int get_size() { return _size; }
			virtual unsigned int get_dim() { return _dim; }

			virtual enosc::host_vector const & get_epsilons() { return _epsilons; }
			virtual enosc::host_vector const & get_betas() { return _betas; }

			/* phase space */
		protected:

			enosc::device_vector _state; /* phase state */

			enosc::device_vector _deriv_det; /* vector field */
			enosc::device_vector _deriv_stoch;

		public:

			virtual enosc::device_vector const & get_state() { return _state; }

			virtual void init( unsigned int seed, bool det = true, bool stoch = true );

	};

}

#endif /* ENOSC_ENSEMBLE_H */

