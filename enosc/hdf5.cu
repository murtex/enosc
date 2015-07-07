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

		/* base call */
	enosc::Observer::configure( config, groupname );

}

	/* observation */
void enosc::HDF5::init( std::string const & filename )
{

		/* create dataset file */
	_file = H5::H5File( filename.c_str(), H5F_ACC_TRUNC );

}

void enosc::HDF5::observe( enosc::Ensemble & ensemble, enosc::scalar time )
{
}

