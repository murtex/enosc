/**
 * hdf5.cu
 * 20150704
 *
 * hdf5 observer
 */

	/* includes */
#include "hdf5.h"

	/* con/destruction */
enosc::HDF5::HDF5()
{
}

enosc::HDF5::~HDF5()
{
}

	/* configuration */
void enosc::HDF5::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call/settings */
	enosc::Observer::configure( config, groupname );

}

