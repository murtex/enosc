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
void enosc::Euler::integrate( enosc::Ensemble & ensemble, enosc::scalar time )
{

		/* get state and derivative */
	enosc::device_vector & state = ensemble.get_state();
	enosc::device_vector const & deriv = ensemble.compute_deriv( state, time );

		/* evolve state (x + dt*dxdt) */
	thrust::transform(
		state.begin(), state.end(),
		thrust::make_transform_iterator(
			deriv.begin(), thrust::placeholders::_1 * _dt ),
		state.begin(),
		thrust::plus< enosc::scalar >() );

}

