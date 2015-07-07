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
	}

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "oscillators: " << _oscillators << "\n";

}

