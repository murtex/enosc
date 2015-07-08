/**
 * hdf5.cu
 * 20150704
 *
 * hdf5 observer
 */

	/* includes */
#include "hdf5.h"

#include <typeinfo>

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
void enosc::HDF5::init( enosc::Ensemble const & ensemble, enosc::Stepper const & stepper, std::string const & filename )
{

		/* base call */
	enosc::Observer::init( ensemble, stepper, filename );

		/* create file */
	_file = H5::H5File( filename.c_str(), H5F_ACC_TRUNC );

		/* set datatype */
	if ( typeid( enosc::scalar ) == typeid( float ) )
		_datatype = H5::PredType::NATIVE_FLOAT;
	else if ( typeid( enosc::scalar ) == typeid( double ) )
		_datatype = H5::PredType::NATIVE_DOUBLE;
	else
		throw std::runtime_error( "invalid type: enosc::HDF5::init, enosc::scalar" );

		/* create static datasets */
	hsize_t dims = ensemble.get_epsilons().size();
	H5::DataSet dataset = _file.createDataSet( "epsilons", _datatype, H5::DataSpace( 1, &dims ) );
	dataset.write( enosc::host_vector( ensemble.get_epsilons() ).data(), _datatype );

	dims = ensemble.get_betas().size();
	dataset = _file.createDataSet( "betas", _datatype, H5::DataSpace( 1, &dims ) );
	dataset.write( enosc::host_vector( ensemble.get_betas() ).data(), _datatype );

	dims = stepper.get_times().size();
	dataset = _file.createDataSet( "times", _datatype, H5::DataSpace( 1, &dims ) );
	dataset.write( stepper.get_times().data(), _datatype );

		/* initialize dynamic datasets */
	H5::Group group = _file.createGroup( "raw" );
	hsize_t mdims[6] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _oscillators.size(), stepper.get_times().size()};
	mdims[0] = _raw ? (_raw_deriv ? 2 : 1) : 0;
	_raw_osc = group.createDataSet( "oscillators", _datatype, H5::DataSpace( 6, mdims ) );
	mdims[4] = _meanfield ? 1 : 0;
	_raw_mean = group.createDataSet( "meanfield", _datatype, H5::DataSpace( 6, mdims ) );

	group = _file.createGroup( "polar" );
	mdims[0] = _polar ? (_polar_deriv ? 2 : 1) : 0;
	mdims[1] = 2;
	mdims[4] = _oscillators.size();
	_polar_osc = group.createDataSet( "oscillators", _datatype, H5::DataSpace( 6, mdims ) );
	mdims[4] = _meanfield ? 1 : 0;
	_polar_mean = group.createDataSet( "meanfield", _datatype, H5::DataSpace( 6, mdims ) );

}

void enosc::HDF5::observe( enosc::Ensemble & ensemble, unsigned int step )
{

		/* write raw */
	if ( _raw ) {

			/* state */
		hsize_t dims_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), ensemble.get_size()};
		H5::DataSpace dataspace_in( 4, dims_in );
		hsize_t starts_in[4] = {0, 0, 0, 0};
		hsize_t counts_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _oscillators.size()};
		dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

		H5::DataSpace dataspace_out( _raw_osc.getSpace() );
		hsize_t starts_out[6] = {0, 0, 0, 0, 0, step};
		hsize_t counts_out[6] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _oscillators.size(), 1};
		dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

		_raw_osc.write( enosc::host_vector( ensemble.get_state() ).data(), _datatype, dataspace_in, dataspace_out );

			/* meanfield */
		if ( _meanfield ) {

			dims_in[3] = 1;
			dataspace_in = H5::DataSpace( 4, dims_in );
			counts_in[3] = 1;
			dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

			dataspace_out = _raw_mean.getSpace();
			counts_out[4] = 1;
			dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

			_raw_mean.write( enosc::host_vector( ensemble.compute_mean( ensemble.get_state() ) ).data(), _datatype, dataspace_in, dataspace_out );

		}

	}

}

