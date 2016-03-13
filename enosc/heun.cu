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
	_tmp3.resize( ensemble.get_dim() * ensemble.get_epsilons().size() * ensemble.get_betas().size() * ensemble.get_size() );

}

void enosc::Heun::integrate( enosc::Ensemble & ensemble, unsigned int step )
{

		/* prepare variables */
	unsigned int const dim = ensemble.get_dim();
	unsigned int const size = ensemble.get_size();
	unsigned int const epsilons = ensemble.get_epsilons().size();
	unsigned int const betas = ensemble.get_betas().size();

	enosc::device_vector const & state = ensemble.get_state();
	enosc::device_vector const & deriv = ensemble.get_deriv();

	enosc::device_vector & next = ensemble.get_state_next();

		/* intermediate value */
	next = state;

	bool fdet = ensemble.compute_deriv_det( state, _times[step] );
	if ( fdet ) {
		_tmp1 = deriv;

		thrust::transform(
			state.begin(), state.end(),
			thrust::make_transform_iterator(
				_tmp1.begin(),
				thrust::placeholders::_1 * _dt ),
			next.begin(),
			thrust::plus< enosc::scalar >() );
	}

	bool fstoch = ensemble.compute_deriv_stoch( state, _times[step] );
	if ( fstoch ) {
		_tmp2 = deriv;

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
			_tmp2.begin(), _tmp2.end(),
			_drandom.begin(),
			_tmp3.begin(),
			thrust::multiplies< enosc::scalar >() );

		thrust::transform(
			next.begin(), next.end(),
			_tmp3.begin(),
			next.begin(),
            thrust::plus< enosc::scalar >() );

	}

		/* final value */
	if ( fdet ) {
		ensemble.compute_deriv_det( next, _times[step] + _dt );
		thrust::transform(
			_tmp1.begin(), _tmp1.end(),
			deriv.begin(),
			_tmp1.begin(),
			thrust::plus< enosc::scalar >() );
	}

	if ( fstoch ) {
		ensemble.compute_deriv_stoch( next, _times[step] + _dt );
		thrust::transform(
			_tmp2.begin(), _tmp2.end(),
			deriv.begin(),
			_tmp2.begin(),
			thrust::plus< enosc::scalar >() );

		thrust::transform(
			_tmp2.begin(), _tmp2.end(),
			thrust::make_transform_iterator(
				_drandom.begin(),
				thrust::placeholders::_1 / 2 ),
			_tmp2.begin(),
			thrust::multiplies< enosc::scalar >() );
	}

	next = state;
	if ( fdet )
		thrust::transform(
			next.begin(), next.end(),
			thrust::make_transform_iterator(
				_tmp1.begin(),
				thrust::placeholders::_1 * _dt/2 ),
			next.begin(),
			thrust::plus< enosc::scalar >() );
	if ( fstoch )
		thrust::transform(
			next.begin(), next.end(),
			_tmp2.begin(),
			next.begin(),
			thrust::plus< enosc::scalar >() );

}


