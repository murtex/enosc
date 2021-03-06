/**
 * observer.cu
 * 20150704
 *
 * observer interface
 */

	/* includes */
#include "observer.h"

#include <xis/singleton.h>
#include <xis/logger.h>

#include <enosc/kernels.h>

	/* con/destruction */
enosc::Observer::Observer()
{

		/* default configuration */
	_oscillator = true; /* observables */
	_ensemble = true;
	_meanfield = true;

	_transition = 0; /* tracking */

	_centering = true;

	_track_raw = true;
	_track_polar = true;
	_track_funnel = true;

}

enosc::Observer::~Observer()
{
}

	/* configuration */
void enosc::Observer::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* parse group settings */
	std::string settingname = groupname + "/oscillator";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _oscillator );

	settingname = groupname + "/ensemble";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _ensemble );

	settingname = groupname + "/meanfield";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _meanfield );

	settingname = groupname + "/transition_steps";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _transition );

	settingname = groupname + "/centering";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _centering );

	settingname = groupname + "/track_raw";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _track_raw );

	settingname = groupname + "/track_polar";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _track_polar );

	settingname = groupname + "/track_funnel";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _track_funnel );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "oscillator: " << _oscillator << "\n";
	logger.log() << "ensemble: " << _ensemble << "\n";
	logger.log() << "meanfield: " << _meanfield << "\n";

	logger.log() << "transition: " << _transition << "\n";
	logger.log() << "centering: " << _centering << "\n";
	logger.log() << "track_raw: " << _track_raw << "\n";
	logger.log() << "track_polar: " << _track_polar << "\n";
	logger.log() << "track_funnel: " << _track_funnel << "\n";

}

	/* observation */
void enosc::Observer::init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename )
{

		/* safeguard */
	if ( _oscillator && ensemble.get_size() < 1 )
		throw std::runtime_error( "invalid value (enosc::Observer::init): _oscillator" );

	if ( _transition > stepper.get_times().size()-1 )
		throw std::runtime_error( "invalid value (enosc::Observer::init): _transition" );

		/* prepare buffers */
	_center.resize( ensemble.get_dim() * ensemble.get_epsilons().size() * ensemble.get_betas().size() ); /* ensemble center */
	_funnel.resize( ensemble.get_epsilons().size() * ensemble.get_betas().size() ); /* funnel indicator */
	_tmp.resize( _center.size() ); /* temporary buffer */

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	size_t cuda_free;
	size_t cuda_total;
	cudaMemGetInfo( &cuda_free, &cuda_total );
	logger.log() << "cuda: " << ((cuda_total-cuda_free)>>20) << "/" << (cuda_total>>20) << "MiB\n";

}

void enosc::Observer::compute_funnel( enosc::device_vector const & polar_deriv, unsigned int size )
{

		/* safeguard */
	if ( polar_deriv.size() % _funnel.size() != 0 )
		throw std::runtime_error( "invalid argument (enosc::Observer::compute_funnel): polar_deriv" );

		/* get minimum frequencies */
	unsigned int stride = _funnel.size();

	thrust::reduce_by_key(

		thrust::make_transform_iterator( /* input keys */
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / size ),
		thrust::make_transform_iterator(
			thrust::counting_iterator< unsigned int >( 0 ),
			thrust::placeholders::_1 / size ) + stride * size,

		polar_deriv.begin() + stride * size, /* input frequencies */

		thrust::make_discard_iterator(), _funnel.begin(), /* output keys, minima */
		
		thrust::equal_to< unsigned int >(), thrust::minimum< enosc::scalar >() );

		/* zero positive frequencies */
	thrust::transform_if(
		_funnel.begin(), _funnel.begin() + stride * size,
		_funnel.begin(),
		enosc::SetZero(), enosc::IsPositive() );

}

