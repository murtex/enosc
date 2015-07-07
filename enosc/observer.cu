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

	/* con/destruction */
enosc::Observer::Observer()
{
}

enosc::Observer::~Observer()
{
}

	/* configuration */
void enosc::Observer::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* parse group settings */
	std::string settingname = groupname + "/oscillators";
	if ( config.exists( settingname ) ) {
		unsigned int n = config.lookup( settingname ).getLength();

		_oscillators.resize( n );
		for ( unsigned int i = 0; i < n; ++i )
			_oscillators[i] = config.lookup( settingname )[i];
	}

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "oscillators: " << _oscillators << "\n";

}

	/* observation */
void enosc::Observer::init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename )
{

		/* safeguard */
	for ( std::vector< unsigned int >::iterator it = _oscillators.begin(); it != _oscillators.end(); ++it )
		if ( (*it)-1 >= ensemble.get_size() )
			throw std::runtime_error( "invalid value: enosc::Observer::init, _oscillators" );
}


