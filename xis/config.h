/**
 * config.h
 * 20150701
 *
 * configurable interface
 */
#ifndef XIS_CONFIG_H
#define XIS_CONFIG_H

	/* includes */
#include <string>

#include <libconfig.h++>

	/* interface */
namespace xis
{

		/* configurable */
	class Config
	{

			/* con/destruction */
		public:

			Config();
			virtual ~Config();

			/* configuration */
		public:
		
			virtual void configure( libconfig::Config const & config, std::string const & groupname ) = 0;

	};

}

#endif /* XIS_CONFIG_H */

