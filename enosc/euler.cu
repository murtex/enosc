/**
 * euler.cu
 * 20150706
 *
 * euler stepper
 */

	/* includes */
#include "euler.h"

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

		/* evolve state */
	enosc::device_vector const & state = ensemble.get_state();
	enosc::device_vector const & deriv = ensemble.get_deriv();

	enosc::device_vector & state_next = ensemble.get_state_next();
	state_next = state;

	if ( ensemble.compute_deriv_det( state, _times[step] ) ) /* deterministic component */
		thrust::transform(
			state_next.begin(), state_next.end(),
			thrust::make_transform_iterator(
				deriv.begin(), thrust::placeholders::_1 * _dt ),
			state_next.begin(),
			thrust::plus< enosc::scalar >() );

	if ( ensemble.compute_deriv_stoch( state, _times[step], _random ) ) /* stochastic component */
		thrust::transform(
			state_next.begin(), state_next.end(),
			thrust::make_transform_iterator(
				deriv.begin(), thrust::placeholders::_1 * _dt ),
			state_next.begin(),
			thrust::plus< enosc::scalar >() );

}

