/**
 * roessler_mod.h
 * 20150704
 *
 * modified roessler ensemble
 */
#ifndef ENOSC_ROESSLER_MOD_H
#define ENOSC_ROESSLER_MOD_H

	/* includes */
#include <enosc/roessler.h>

	/* interface */
namespace enosc
{

		/* modified roessler ensemble */
	class RoesslerMod : public enosc::Roessler
	{

			/* con/destruction */
		public:

			RoesslerMod();
			~RoesslerMod() {}

			/* configuration */
		private:

			double _e; /* modified roessler parameters */
			double _f;

		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

	};

}

#endif /* ENOSC_ROESSLER_MOD_H */

