/**
 * ensemble.cu
 * 20150703
 *
 * ensemble interface
 */

	/* includes */
#include "ensemble.h"

#include <xis/singleton.h>
#include <xis/logger.h>

	/* con/destruction */
enosc::Ensemble::Ensemble()
{

		/* initialize configuration */
	_size = 0;
	_dim = 0;

}

	/* configuration */
void enosc::Ensemble::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* parse group settings */
	std::string settingname = groupname + "/size";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _size );

	std::string paramname = groupname + "/epsilon";
	std::string stepname = groupname + "/epsilon_steps";
	if ( config.exists( paramname ) && config.exists( stepname ) ) {

			/* read settings */
		enosc::scalar start = config.lookup( paramname )[0];
		enosc::scalar stop = config.lookup( paramname )[1];

		unsigned int steps = config.lookup( stepname );

			/* set parameter values */
		_epsilons.resize( steps+1 );
		_epsilons[0] = start;
		for ( unsigned int i = 1; i < steps+1; ++i )
			_epsilons[i] = start + i * (stop-start) / (enosc::scalar) steps;

	}

	paramname = groupname + "/beta";
	stepname = groupname + "/beta_steps";
	if ( config.exists( paramname ) && config.exists( stepname ) ) {

			/* read settings */
		enosc::scalar start = config.lookup( paramname )[0];
		enosc::scalar stop = config.lookup( paramname )[1];

		unsigned int steps = config.lookup( stepname );

			/* set parameter values */
		_betas.resize( steps+1 );
		_betas[0] = start;
		for ( unsigned int i = 1; i < steps+1; ++i )
			_betas[i] = start + i * (stop-start) / (enosc::scalar) steps;

	}

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "size: " << _size << "\n";
	logger.log() << "dim: " << _dim << "\n";

	logger.log() << "epsilons: " << _epsilons << "\n";
	logger.log() << "betas: " << _betas << "\n";

}

	/* phase space */
void enosc::Ensemble::init( unsigned int seed, bool det, bool stoch )
{

		/* safeguard */
	if ( !det && !stoch )
		throw std::runtime_error( "invalid values: enosc::Ensemble::init, det | stoch" );

	if ( _dim < 2 || _epsilons.size() == 0 || _betas.size() == 0 || _size == 0 )
		throw std::runtime_error( "invalid values: enosc::Ensemble::init, _dim | _epsilons | _betas | _size" );

		/* prepare buffers */
	_state.resize( _dim * _epsilons.size() * _betas.size() * _size ); /* phase state */

	if ( det ) /* derivatives */
		_deriv_det.resize( _state.size() );
	if ( stoch )
		_deriv_stoch.resize( _state.size() );

	_mean.resize( _dim * _epsilons.size() * _betas.size() ); /* ensemble mean */

		/* initialize randomness */
	srand( seed );

		/* logging */
	size_t cuda_free;
	size_t cuda_total;

	cudaMemGetInfo( &cuda_free, &cuda_total );

	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "cuda: " << ((cuda_total-cuda_free)>>20) << "/" << (cuda_total>>20) << "MiB\n";

}

	/* computation */
enosc::device_vector const & enosc::Ensemble::compute_deriv( enosc::device_vector const & state, enosc::scalar time )
{

		/* safeguard */
	if ( state.size() != _state.size() )
		throw std::runtime_error( "invalid value: enosc::Ensemble::compute_deriv, state" );

		/* return pure deterministic/stochastic derivative */
	if ( _deriv_det.size() == 0 )
		return compute_deriv_stoch( state, time );

	else if ( _deriv_stoch.size() == 0 )
		return compute_deriv_det( state, time );

		/* return composite derivative */
	compute_deriv_det( state, time );
	compute_deriv_stoch( state, time );

	thrust::transform(
		_deriv_det.begin(), _deriv_det.end(), /* summands input */
		_deriv_stoch.begin(),
		_deriv_det.begin(), /* sum output */
		thrust::plus< enosc::scalar >() );

	return _deriv_det;
}

enosc::device_vector const & enosc::Ensemble::compute_mean( enosc::device_vector const & buf )
{

		/* safeguard */
	if ( buf.size() != _state.size() )
		throw std::runtime_error( "invalid value: enosc::Ensemble::compute_mean, buf" );

		/* average ensemble */
	thrust::reduce_by_key(

		thrust::make_transform_iterator( /* keys */
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / _size ),
		thrust::make_transform_iterator(
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / _size ) + buf.size(),

		thrust::make_transform_iterator( /* scaled input */
			buf.begin(), thrust::placeholders::_1 / _size ),

		thrust::make_discard_iterator(), _mean.begin() ); /* keys, mean output */

	return _mean;
}

