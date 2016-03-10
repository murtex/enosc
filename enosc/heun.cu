/**
 * heun.cu
 * 20160310
 *
 * heun stepper
 */

	/* includes */
#include "heun.h"

	/* configuration */
void enosc::Heun::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Stepper::configure( config, groupname );

}

	/* integration */
void enosc::Heun::init( enosc::Ensemble const & ensemble )
{

		/* base call */
	enosc::Stepper::init( ensemble );

		/* prepare buffers */
	_tmp1.resize( ensemble.get_dim() * ensemble.get_epsilons().size() * ensemble.get_betas().size() * ensemble.get_size() );
	_tmp2.resize( ensemble.get_dim() * ensemble.get_epsilons().size() * ensemble.get_betas().size() * ensemble.get_size() );

}

void enosc::Heun::integrate( enosc::Ensemble & ensemble, unsigned int step )
{

		/* evolve state */
	unsigned int const dim = ensemble.get_dim();
	unsigned int const size = ensemble.get_size();
	unsigned int const epsilons = ensemble.get_epsilons().size();
	unsigned int const betas = ensemble.get_betas().size();

	enosc::device_vector const & state = ensemble.get_state();
	enosc::device_vector const & deriv = ensemble.get_deriv();

	enosc::device_vector & state_next = ensemble.get_state_next();
	state_next = state;

	if ( ensemble.compute_deriv_det( state, _times[step] ) ) { /* deterministic component */

		_tmp1 = state_next; /* intermediate values */
		thrust::transform(
			_tmp1.begin(), _tmp1.end(),
			thrust::make_transform_iterator(
				deriv.begin(), thrust::placeholders::_1 * _dt ),
			_tmp1.begin(),
			thrust::plus< enosc::scalar >() );

		_tmp2 = deriv;
		ensemble.compute_deriv_det( _tmp1, _times[step] + _dt );
		thrust::transform(
			_tmp2.begin(), _tmp2.end(),
			deriv.begin(),
			_tmp2.begin(),
			thrust::plus< enosc::scalar >() );

		thrust::transform( /* final value */
			state_next.begin(), state_next.end(),
			thrust::make_transform_iterator(
				_tmp2.begin(), thrust::placeholders::_1 * _dt/2 ),
			state_next.begin(),
			thrust::plus< enosc::scalar >() );

	}

	if ( ensemble.compute_deriv_stoch( state, _times[step] ) ) { /* stochastic component, TODO: this is euler method! */

			/* (re-)randomize */
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

			/* evolve */
        thrust::transform(
			deriv.begin(), deriv.end(),
			_drandom.begin(),
			_drandom.begin(),
			thrust::multiplies< enosc::scalar >() );

		thrust::transform(
			state_next.begin(), state_next.end(),
			_drandom.begin(),
			state_next.begin(),
            thrust::plus< enosc::scalar >() );

	}

}


