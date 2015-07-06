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

		/* prepare phase space buffers */
	_state.resize( _dim * _size * _epsilons.size() * _betas.size() );

	if ( det )
		_deriv_det.resize( _state.size() );
	if ( stoch )
		_deriv_stoch.resize( _state.size() );

		/* initialize randomness */
	srand( seed );

}

