/**
 * euler.cu
 * 20150706
 *
 * euler stepper
 */

	/* includes */
#include "euler.h"

#include <xis/singleton.h>
#include <xis/logger.h>

	/* configuration */
void enosc::Euler::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Stepper::configure( config, groupname );

}

	/* integration */
void enosc::Euler::init( enosc::Ensemble const & ensemble )
{

		/* base call */
	enosc::Stepper::init( ensemble );

}

void enosc::Euler::integrate( enosc::Ensemble & ensemble, unsigned int step )
{

		/* prepare variables */
	unsigned int const dim = ensemble.get_dim();
	unsigned int const size = ensemble.get_size();
	unsigned int const epsilons = ensemble.get_epsilons().size();
	unsigned int const betas = ensemble.get_betas().size();

	enosc::device_vector const & state = ensemble.get_state();
	enosc::device_vector const & deriv = ensemble.get_deriv();

	enosc::device_vector & next = ensemble.get_state_next();

		/* evolve state */
	next = state;

	bool fdet = ensemble.compute_deriv_det( state, _times[step] ); /* deterministic part */
	if ( fdet )
		thrust::transform(
			next.begin(), next.end(),
			thrust::make_transform_iterator(
				deriv.begin(),
				thrust::placeholders::_1 * _dt ),
			next.begin(),
			thrust::plus< enosc::scalar >() );

	bool fstoch = ensemble.compute_deriv_stoch( state, _times[step] ); /* stochastic part */
	if ( fstoch ) {

			/* prepare randomness */
        for ( auto it = _hrandom.begin(); it != _hrandom.end(); ++it )
			*it = (*_rnd)( _rng );

		for ( unsigned int i = 0; i < dim; ++i )
			thrust::copy_n(
				thrust::make_permutation_iterator(
					_hrandom.begin() + i * size,
					thrust::make_transform_iterator(
						thrust::counting_iterator< unsigned int >( 0 ),
						thrust::placeholders::_1 % size ) ),
				epsilons * betas * size,
				_drandom.begin() + i * epsilons * betas * size );

			/* update next state */
        thrust::transform(
			deriv.begin(), deriv.end(),
			_drandom.begin(),
			_drandom.begin(),
			thrust::multiplies< enosc::scalar >() );

		thrust::transform(
			next.begin(), next.end(),
			_drandom.begin(),
			next.begin(),
            thrust::plus< enosc::scalar >() );

	}

}

