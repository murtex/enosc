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

			H5::H5File _file; /* datafile */

			H5::DataType _datatype; /* datatype */

			H5::DataSet _raw_x; /* dynamic datasets */
			H5::DataSet _raw_dxdt;
			H5::DataSet _raw_mx;
			H5::DataSet _raw_dmxdt;

			H5::DataSet _polar_x;
			H5::DataSet _polar_dxdt;
			H5::DataSet _polar_mx;
			H5::DataSet _polar_dmxdt;
			H5::DataSet _polar_mf;
			H5::DataSet _polar_dmfdt;

		public:

			void init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename );

			void observe( enosc::Ensemble & ensemble, unsigned int step, enosc::scalar time );

	};

}

#endif /* ENOSC_HDF5_H */

