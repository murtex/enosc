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
void enosc::Euler::integrate( enosc::Ensemble & ensemble, unsigned int step )
{

		/* evolution */
	/*ensemble.evolve_det( _times[step] );
	 *enosc::device_vector const & deriv = ensemble.get_deriv_det();*/

		/* x + dt*dxdt */
/*    enosc::device_vector & state = ensemble.get_state();
 *
 *    thrust::transform(
 *        state.begin(), state.end(),
 *        thrust::make_transform_iterator(
 *            deriv.begin(), thrust::placeholders::_1 * _dt ),
 *        state.begin(),
 *        thrust::plus< enosc::scalar >() );*/

}

