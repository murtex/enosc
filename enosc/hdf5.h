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
		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* observation */
		private:

			H5::H5File _file; /* dataset file */

			H5::DataType _datatype; /* in/out datatype */

			H5::DataSet _raw_osc; /* dynamic datasets */
			H5::DataSet _raw_mean;
			H5::DataSet _polar_osc;
			H5::DataSet _polar_mean;

		public:

			void init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename );

			void observe( enosc::Ensemble & ensemble, unsigned int step );

	};

}

#endif /* ENOSC_HDF5_H */

