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

			unsigned int _seed; /* randomization seed */

			unsigned int _size; /* ensemble size */
			unsigned int _dim; /* dimensionality */

			enosc::device_vector _epsilons; /* coupling */
			enosc::device_vector _betas;

		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

			unsigned int get_size() const { return _size; }
			unsigned int get_dim() const { return _dim; }

			enosc::device_vector const & get_epsilons() const { return _epsilons; }
			enosc::device_vector const & get_betas() const { return _betas; }

			/* phase space */
		protected:

			enosc::device_vector _state; /* double buffered state */
			enosc::device_vector _state_next;

			enosc::device_vector _polar; /* polar transform */
			enosc::device_vector _deriv; /* derivative */

			enosc::device_vector _mean; /* ensemble mean */

		public:

			virtual void init();

			void swap();

			virtual void compute_polar( enosc::device_vector const & buf, enosc::device_vector const & buf_deriv );
			void compute_mean( enosc::device_vector const & buf );

			enosc::device_vector & get_state() { return _state; }
			enosc::device_vector & get_state_next() { return _state_next; }

			enosc::device_vector & get_polar() { return _polar; }
			enosc::device_vector & get_deriv() { return _deriv; }

			enosc::device_vector & get_mean() { return _mean; }

			/* ode */
		public:

			virtual bool compute_deriv_det( enosc::device_vector const & state, enosc::scalar time ) { return false; }
			virtual bool compute_deriv_stoch( enosc::device_vector const & state, enosc::scalar time, enosc::device_vector const & random ) { return false; }

	};

}

#endif /* ENOSC_ENSEMBLE_H */

