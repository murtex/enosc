/**
 * hdf5.h
 * 20150704
 *
 * hdf5 observer
 */
#ifndef ENOSC_HDF5_H
#define ENOSC_HDF5_H

	/* includes */
#include <enosc/observer.h>

	/* interface */
namespace enosc
{

		/* hdf5 observer */
	class HDF5 : public enosc::Observer
	{

			/* con/destructor */
		public:

			HDF5();
			~HDF5();

			/* configuration */
		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

	};

}

#endif /* ENOSC_HDF5_H */

