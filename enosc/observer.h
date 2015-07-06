/**
 * observer.h
 * 20150704
 *
 * observer interface
 */
#ifndef ENOSC_OBSERVER_H
#define ENOSC_OBSERVER_H

	/* includes */
#include <xis/config.h>

#include <enosc/types.h>

	/* interface */
namespace enosc
{

		/* observer */
	class Observer : public xis::Config
	{

			/* con/destruction */
		public:

			Observer();
			virtual ~Observer();

			/* configuration */
		public:

			virtual void configure( libconfig::Config const & config, std::string const & groupname );

	};

}

#endif /* ENOSC_OBSERVER_H */

