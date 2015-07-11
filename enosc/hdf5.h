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

#include <H5Cpp.h>

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
		private:

			unsigned int _deflate; /* compression */

		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* observation */
		private:

			H5::H5File _file; /* dataset file */

			H5::DataType _datatype; /* in/out datatype */

			H5::DataSet _raw_x; /* dynamic datasets */
			H5::DataSet _raw_dxdt;
			H5::DataSet _raw_mf;
			H5::DataSet _raw_dmfdt;

		public:

			void init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename );

			void observe( enosc::Ensemble & ensemble, unsigned int step, enosc::scalar time );

	};

}

#endif /* ENOSC_HDF5_H */

