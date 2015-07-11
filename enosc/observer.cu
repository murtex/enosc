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

		/* default configuration */
	_size = 1;
	_meanfield = true;

}

enosc::Observer::~Observer()
{
}

	/* configuration */
void enosc::Observer::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* parse group settings */
	std::string settingname = groupname + "/size";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _size );

	settingname = groupname + "/meanfield";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _meanfield );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "size: " << _size << "\n";
	logger.log() << "meanfield: " << _meanfield << "\n";

}

	/* observation */
void enosc::Observer::init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename )
{

		/* safeguard */
	if ( _size > ensemble.get_size() )
		throw std::runtime_error( "invalid value: enosc::Observer::init, _size" );

}


