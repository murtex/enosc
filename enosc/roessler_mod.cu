/**
 * roessler_mod.cu
 * 20150704
 *
 * modified roessler ensemble
 */

	/* includes */
#include "roessler_mod.h"

#include <xis/singleton.h>
#include <xis/logger.h>

	/* interface */
enosc::RoesslerMod::RoesslerMod()
{

		/* initialize configuration */
	_c = 10.0;

	_e = 0.15;
	_f = 0.2;

}

	/* configuration */
void enosc::RoesslerMod::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Roessler::configure( config, groupname );

		/* parse group settings */
	std::string settingname = groupname + "/e";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _e );

	settingname = groupname + "/f";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _f );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "e: " << _e << "\n";
	logger.log() << "f: " << _f << "\n";

}

