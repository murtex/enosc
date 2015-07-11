/**
 * hdf5.cu
 * 20150704
 *
 * hdf5 observer
 */

	/* includes */
#include "hdf5.h"

#include <xis/singleton.h>
#include <xis/logger.h>

#include <typeinfo>

	/* con/destruction */
enosc::HDF5::HDF5()
{

		/* default configuration */
	_deflate = 0;

}

enosc::HDF5::~HDF5()
{
}

	/* configuration */
void enosc::HDF5::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Observer::configure( config, groupname );

		/* parse group settings */
	std::string settingname = groupname + "/deflate";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _deflate );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "deflate: " << _deflate << "\n";

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
	H5::DataSet dataset = _file.createDataSet( "size", _datatype, H5::DataSpace() );
	dataset.write( &_size, H5::PredType::NATIVE_UINT );

	dataset = _file.createDataSet( "dim", _datatype, H5::DataSpace() );
	unsigned int dim = ensemble.get_dim();
	dataset.write( &dim, H5::PredType::NATIVE_UINT );

	hsize_t dims = ensemble.get_epsilons().size();
	dataset = _file.createDataSet( "epsilons", _datatype, H5::DataSpace( 1, &dims ) );
	enosc::device_vector const & epsilons = ensemble.get_epsilons();
	dataset.write( enosc::host_vector( epsilons.begin(), epsilons.end() ).data(), _datatype );

	dims = ensemble.get_betas().size();
	dataset = _file.createDataSet( "betas", _datatype, H5::DataSpace( 1, &dims ) );
	enosc::device_vector const & betas = ensemble.get_betas();
	dataset.write( enosc::host_vector( betas.begin(), betas.end() ).data(), _datatype );

	dims = stepper.get_times().size();
	dataset = _file.createDataSet( "times", _datatype, H5::DataSpace( 1, &dims ) );
	dataset.write( stepper.get_times().data(), _datatype );

		/* initialize dynamic datasets */
	H5::Group group = _file.createGroup( "raw" );

	H5::DSetCreatPropList props; /* oscillators */
	hsize_t chunks[5] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _size};
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	hsize_t mdims[5] = {stepper.get_times().size(), ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _size};
	_raw_x = group.createDataSet( "x", _datatype, H5::DataSpace( 5, mdims ), props );
	_raw_dxdt = group.createDataSet( "dxdt", _datatype, H5::DataSpace( 5, mdims ), props );

	chunks[4] = _meanfield ? 1 : 0; /* meanfield */
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	mdims[4] = _meanfield ? 1 : 0;
	_raw_mf = group.createDataSet( "mf", _datatype, H5::DataSpace( 5, mdims ), props );
	_raw_dmfdt = group.createDataSet( "dmfdt", _datatype, H5::DataSpace( 5, mdims ), props );

}

void enosc::HDF5::observe( enosc::Ensemble & ensemble, unsigned int step, enosc::scalar time )
{

		/* write oscillators */
	hsize_t dims_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), ensemble.get_size()};
	H5::DataSpace dataspace_in( 4, dims_in );
	hsize_t starts_in[4] = {0, 0, 0, 0};
	hsize_t counts_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _size};
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	H5::DataSpace dataspace_out( _raw_x.getSpace() );
	hsize_t starts_out[5] = {step, 0, 0, 0, 0};
	hsize_t counts_out[5] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), _size};
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	enosc::device_vector const & state = ensemble.get_state();
	_raw_x.write( enosc::host_vector( state.begin(), state.end() ).data(), _datatype, dataspace_in, dataspace_out );

    enosc::device_vector const & deriv = ensemble.compute_deriv( state, time );
    _raw_dxdt.write( enosc::host_vector( deriv.begin(), deriv.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write meanfield */
	dims_in[3] = 1;
	dataspace_in = H5::DataSpace( 4, dims_in );
	counts_in[3] = _meanfield ? 1 : 0;
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	dataspace_out = _raw_mf.getSpace();
	counts_out[4] = _meanfield ? 1 : 0;
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	enosc::device_vector const & mean = ensemble.compute_mean( state );
	_raw_mf.write( enosc::host_vector( mean.begin(), mean.end() ).data(), _datatype, dataspace_in, dataspace_out );

	enosc::device_vector const & meanderiv = ensemble.compute_mean( deriv );
	_raw_dmfdt.write( enosc::host_vector( meanderiv.begin(), meanderiv.end() ).data(), _datatype, dataspace_in, dataspace_out );

}

