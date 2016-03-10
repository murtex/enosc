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

#include <enosc/kernels.h>

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
	std::string settingname = groupname + "/seed";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _seed );

	settingname = groupname + "/size";
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
		for ( unsigned int i = 1; i < steps; ++i )
			_epsilons[i] = start + i * (stop-start) / (enosc::scalar) steps;
		if ( steps >= 1 )
			_epsilons[steps] = stop;

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
		for ( unsigned int i = 1; i < steps; ++i )
			_betas[i] = start + i * (stop-start) / (enosc::scalar) steps;
		if ( steps >= 1 )
			_betas[steps] = stop;

	}

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "seed: " << _seed << "\n";

	logger.log() << "size: " << _size << "\n";
	logger.log() << "dim: " << _dim << "\n";
	logger.log() << "polar: " << _fpolar << "\n";

	logger.log() << "epsilons: " << _epsilons << "\n";
	logger.log() << "betas: " << _betas << "\n";

}

	/* phase space */
void enosc::Ensemble::init()
{

		/* safeguard */
	if ( _dim < 2 || _size == 0 )
		throw std::runtime_error( "invalid values (enosc::Ensemble::init): _dim | _size" );

	if ( _epsilons.size() == 0 || _betas.size() == 0 )
		throw std::runtime_error( "invalid values (enosc::Enesemble::init): _epsilons | _betas" );

		/* prepare buffers */
	_state.resize( _dim * _epsilons.size() * _betas.size() * _size ); /* double buffered state */
	_state_next.resize( _state.size() );

	_polar.resize( 2 * _epsilons.size() * _betas.size() * _size ); /* polar transform */
	_deriv.resize( _state.size() ); /* derivative */

	_mean.resize( _dim * _epsilons.size() * _betas.size() ); /* ensemble mean */

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	size_t cuda_free;
	size_t cuda_total;
	cudaMemGetInfo( &cuda_free, &cuda_total );
	logger.log() << "cuda: " << ((cuda_total-cuda_free)>>20) << "/" << (cuda_total>>20) << "MiB\n";

}

void enosc::Ensemble::swap()
{

		/* swap state buffers */
	_state = _state_next;

}

void enosc::Ensemble::compute_polar( enosc::device_vector const & buf, enosc::device_vector const & buf_deriv )
{

		/* safeguard */
	if ( buf.size() % (_dim * _epsilons.size() * _betas.size()) != 0 ||
			buf_deriv.size() % (_dim * _epsilons.size() * _betas.size()) != 0 )
		throw std::runtime_error( "invalid arguments (enosc::Ensemble::compute_polar): buf | buf_deriv" );

		/* compute polar transform */
	unsigned int size = buf.size() / (_dim * _epsilons.size() * _betas.size()); /* input ensemble size */
	if ( buf_deriv.size() < buf.size() )
		size = buf_deriv.size() / (_dim * _epsilons.size() * _betas.size());

	if ( _fpolar ) /* identity */
		thrust::for_each_n(
			thrust::make_zip_iterator( thrust::make_tuple(

				buf.begin(), /* polar input */
				buf.begin() + _epsilons.size() * _betas.size() * size,
				buf_deriv.begin(),
				buf_deriv.begin() + _epsilons.size() * _betas.size() * size,

				_polar.begin(), /* polar output */
				_polar.begin() + _epsilons.size() * _betas.size() * size,
				_deriv.begin(),
				_deriv.begin() + _epsilons.size() * _betas.size() * size ) ),

			_epsilons.size() * _betas.size() * size, enosc::PolarToPolarFull() );

	else /* cartesian to polar */
		thrust::for_each_n(
			thrust::make_zip_iterator( thrust::make_tuple(

				buf.begin(), /* cartesian input */
				buf.begin() + _epsilons.size() * _betas.size() * size,
				buf_deriv.begin(),
				buf_deriv.begin() + _epsilons.size() * _betas.size() * size,

				_polar.begin(), /* polar output */
				_polar.begin() + _epsilons.size() * _betas.size() * size,
				_deriv.begin(),
				_deriv.begin() + _epsilons.size() * _betas.size() * size ) ),

			_epsilons.size() * _betas.size() * size, enosc::CartesianToPolarFull() );

}

void enosc::Ensemble::compute_mean( enosc::device_vector const & buf )
{

		/* safeguard */
	if ( buf.size() % (_epsilons.size() * _betas.size() * _size) != 0 )
		throw std::runtime_error( "invalid argument (enosc::Ensemble::compute_mean): buf" );

		/* compute ensemble mean */
	thrust::reduce_by_key(

		thrust::make_transform_iterator( /* input keys */
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / _size ),
		thrust::make_transform_iterator(
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / _size ) + buf.size(),

		thrust::make_transform_iterator( /* input summands (scaled) */
			buf.begin(), thrust::placeholders::_1 / _size ),

		thrust::make_discard_iterator(), _mean.begin() ); /* output keys, means */

}

