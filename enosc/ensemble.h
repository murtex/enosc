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

			enosc::device_vector _epsilons; /* complex meanfield coupling */
			enosc::device_vector _betas;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			unsigned int get_size() { return _size; }
			unsigned int get_dim() { return _dim; }

			enosc::device_vector const & get_epsilons() { return _epsilons; }
			enosc::device_vector const & get_betas() { return _betas; }

			/* phase space */
		protected:

			enosc::device_vector _state; /* state */

		public:

			enosc::device_vector & get_state() { return _state; }

			virtual void init( unsigned int seed, bool det = true, bool stoch = true );

			/* computation */
		protected:

			enosc::device_vector _deriv_det; /* derivatives */
			enosc::device_vector _deriv_stoch;

			enosc::device_vector _mean; /* ensemble mean */

		public:

			enosc::device_vector const & compute_deriv( enosc::device_vector const & state, enosc::scalar time );
			virtual enosc::device_vector const & compute_deriv_det( enosc::device_vector const & state, enosc::scalar time ) = 0;
			virtual enosc::device_vector const & compute_deriv_stoch( enosc::device_vector const & state, enosc::scalar time ) = 0;

			enosc::device_vector const & compute_mean( enosc::device_vector const & buf );

	};

}

#endif /* ENOSC_ENSEMBLE_H */

