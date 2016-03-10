/**
 * stepper.cu
 * 20150706
 *
 * stepper interface
 */

	/* includes */
#include "stepper.h"

#include <xis/singleton.h>
#include <xis/logger.h>

	/* con/destruction */
enosc::Stepper::Stepper()
{

		/* initialize configuration */
	_dt = 0;

}

enosc::Stepper::~Stepper()
{

		/* release objects */
	delete _rnd;

}

	/* configuration */
void enosc::Stepper::configure( libconfig::Config const & config, std::string const & groupname )
{

	std::string paramname = groupname + "/time";
	std::string stepname = groupname + "/time_steps";
	if ( config.exists( paramname ) && config.exists( stepname ) ) {

			/* read settings */
		enosc::scalar start = config.lookup( paramname )[0];
		enosc::scalar stop = config.lookup( paramname )[1];

		unsigned int steps = config.lookup( stepname );

			/* set parameter values */
		_times.resize( steps+1 );
		_times[0] = start;
		for ( unsigned int i = 1; i < steps; ++i )
			_times[i] = start + i * (stop-start) / (enosc::scalar) steps;
		if ( steps >= 1 )
			_times[steps] = stop;

		if ( _times.size() > 1 )
			_dt = _times[1] - _times[0];

	}

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "times: " << _times << "\n";

}

	/* integration */
void enosc::Stepper::init( enosc::Ensemble const & ensemble )
{

		/* prepare randomness */
	_rng.seed( ensemble.get_seed() );
	_rnd = new std::normal_distribution< enosc::scalar >( 0, sqrt( _dt ) );

	_hrandom.resize( ensemble.get_dim() * ensemble.get_size() );
	_drandom.resize( ensemble.get_dim() * ensemble.get_epsilons().size() * ensemble.get_betas().size() * ensemble.get_size() );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	size_t cuda_free;
	size_t cuda_total;
	cudaMemGetInfo( &cuda_free, &cuda_total );
	logger.log() << "cuda: " << ((cuda_total-cuda_free)>>20) << "/" << (cuda_total>>20) << "MiB\n";

}

