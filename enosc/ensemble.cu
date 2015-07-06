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

		/* prepare phase space buffers */
	_state.resize( _dim * _size * _epsilons.size() * _betas.size() ); /* phase state */

	if ( det ) /* derivatives */
		_deriv_det.resize( _state.size() );
	if ( stoch )
		_deriv_stoch.resize( _state.size() );

		/* prepare computation buffers */
	_meanfield.resize( _dim * _epsilons.size() * _betas.size() ); /* meanfield */

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

		/* return pure deterministic/stochastic derivative */
	if ( _deriv_det.size() == 0 )
		return compute_deriv_stoch( state, time );

	else if ( _deriv_stoch.size() == 0 )
		return compute_deriv_det( state, time );

		/* return overall derivative */
	enosc::device_vector const & deriv_det = compute_deriv_det( state, time );
	enosc::device_vector const & deriv_stoch = compute_deriv_stoch( state, time );

	thrust::transform(
		deriv_det.begin(), deriv_det.end(),
		deriv_stoch.begin(),
		_deriv_det.begin(),
		thrust::plus< enosc::scalar >() );

	return _deriv_det;
}

