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
		throw std::runtime_error( "invalid type (enosc::HDF5::init): enosc::scalar" );

		/* create static datasets */
	enosc::host_vector const & ctimes = stepper.get_times(); /* times */
	enosc::host_vector times( ctimes.begin() + _transition, ctimes.end() );
	hsize_t dim = times.size();
	H5::DataSet dataset = _file.createDataSet( "times", _datatype, H5::DataSpace( 1, &dim ) );
	dataset.write( times.data(), _datatype );

	enosc::scalar dt = stepper.get_dt(); /* dt */
	dataset = _file.createDataSet( "dt", _datatype, H5::DataSpace() );
	dataset.write( &dt, _datatype );

	enosc::device_vector const & epsilons = ensemble.get_epsilons(); /* epsilons */
	dim = epsilons.size();
	dataset = _file.createDataSet( "epsilons", _datatype, H5::DataSpace( 1, &dim ) );
	dataset.write( enosc::host_vector( epsilons.begin(), epsilons.end() ).data(), _datatype );

	enosc::device_vector const & betas = ensemble.get_betas(); /* betas */
	dim = betas.size();
	dataset = _file.createDataSet( "betas", _datatype, H5::DataSpace( 1, &dim ) );
	dataset.write( enosc::host_vector( betas.begin(), betas.end() ).data(), _datatype );

		/* initialize dynamic datasets */

			/* raw */
	H5::Group group = _file.createGroup( "raw" );

	H5::DSetCreatPropList props; /* oscillators */
	hsize_t chunks[5] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), (hsize_t) (_oscillator ? 1 : 0)};
	chunks[4] = (_oscillator ? 1 : 0) * (_track_raw ? 1 : 0);
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	hsize_t dims[5] = {times.size(), ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), (hsize_t) (_oscillator ? 1 : 0)};
	dims[4] = (_oscillator ? 1 : 0) * (_track_raw ? 1 : 0);
	_raw_x = group.createDataSet( "x", _datatype, H5::DataSpace( 5, dims ), props );
	_raw_dxdt = group.createDataSet( "dxdt", _datatype, H5::DataSpace( 5, dims ), props );

	chunks[4] = (_ensemble ? 1 : 0) * (_track_raw ? 1 : 0); /* mean */
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[4] = (_ensemble ? 1 : 0) * (_track_raw ? 1 : 0);
	_raw_mx = group.createDataSet( "mx", _datatype, H5::DataSpace( 5, dims ), props );
	_raw_dmxdt = group.createDataSet( "dmxdt", _datatype, H5::DataSpace( 5, dims ), props );

			/* polar */
	group = _file.createGroup( "polar" );

	chunks[1] = 2; /* oscillators */
	chunks[4] = (_oscillator ? 1 : 0) * (_track_polar ? 1 : 0);
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[1] = 2;
	dims[4] = (_oscillator ? 1 : 0) * (_track_polar ? 1 : 0);
	_polar_x = group.createDataSet( "x", _datatype, H5::DataSpace( 5, dims ), props );
	_polar_dxdt = group.createDataSet( "dxdt", _datatype, H5::DataSpace( 5, dims ), props );

	chunks[4] = (_ensemble ? 1 : 0) * (_track_polar ? 1 : 0); /* mean */
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[4] = (_ensemble ? 1 : 0) * (_track_polar ? 1 : 0);
	_polar_mx = group.createDataSet( "mx", _datatype, H5::DataSpace( 5, dims ), props );
	_polar_dmxdt = group.createDataSet( "dmxdt", _datatype, H5::DataSpace( 5, dims ), props );

	chunks[4] = (_meanfield ? 1 : 0) * (_track_polar ? 1 : 0); /* meanfield */
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[4] = (_meanfield ? 1 : 0) * (_track_polar ? 1 : 0);
	_polar_mf = group.createDataSet( "mf", _datatype, H5::DataSpace( 5, dims ), props );
	_polar_dmfdt = group.createDataSet( "dmfdt", _datatype, H5::DataSpace( 5, dims ), props );

			/* funnel */
	group = _file.createGroup( "funnel" );

	chunks[1] = 1; /* mean */
	chunks[4] = (_ensemble ? 1 : 0) * (_track_funnel ? 1 : 0);
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[1] = 1;
	dims[4] = (_ensemble ? 1 : 0) * (_track_funnel ? 1 : 0);
	_funnel_mx = group.createDataSet( "mx", _datatype, H5::DataSpace( 5, dims ), props );

	chunks[4] = (_meanfield ? 1 : 0) * (_track_funnel ? 1 : 0); /* meanfield */
	if ( _deflate != 0 ) {
		props.setChunk( 5, chunks );
		props.setDeflate( _deflate );
		props.setShuffle();
	}

	dims[4] = (_meanfield ? 1 : 0) * (_track_funnel ? 1 : 0);
	_funnel_mf = group.createDataSet( "mf", _datatype, H5::DataSpace( 5, dims ), props );

}

void enosc::HDF5::observe( enosc::Ensemble & ensemble, unsigned int step, enosc::scalar time )
{

		/* prepare buffers */
	enosc::device_vector & state = ensemble.get_state();
	enosc::device_vector const & state_next = ensemble.get_state_next();
	
	enosc::device_vector & polar = ensemble.get_polar();
	enosc::device_vector & deriv = ensemble.get_deriv();

	enosc::device_vector & mean = ensemble.get_mean();

		/* update ensemble center (transition phase) */
	if ( step < _transition ) {
		if ( _centering ) {
			ensemble.compute_mean( state );

			thrust::transform(
				_center.begin(), _center.end(),
				thrust::make_transform_iterator(
					mean.begin(), thrust::placeholders::_1 / _transition ),
				_center.begin(), thrust::plus< enosc::scalar >() );
		}

		return;
	}

		/* write raw oscillators */
	hsize_t dims_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), ensemble.get_size()};
	hsize_t starts_in[4] = {0, 0, 0, 0};
	hsize_t counts_in[4] = {ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), (hsize_t) (_oscillator ? 1 : 0) * (_track_raw ? 1 : 0)};
	H5::DataSpace dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	hsize_t starts_out[5] = {step - _transition, 0, 0, 0, 0};
	hsize_t counts_out[5] = {1, ensemble.get_dim(), ensemble.get_epsilons().size(), ensemble.get_betas().size(), (hsize_t) (_oscillator ? 1 : 0) * (_track_raw ? 1 : 0)};
	H5::DataSpace dataspace_out = _raw_x.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	_raw_x.write( enosc::host_vector( state.begin(), state.end() ).data(), _datatype, dataspace_in, dataspace_out );

	thrust::transform( /* compute derivative */
		state_next.begin(), state_next.end(),
		state.begin(),
		deriv.begin(), thrust::minus< enosc::scalar >() );

	_raw_dxdt.write( enosc::host_vector( deriv.begin(), deriv.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write polar oscillators */
	dims_in[0] = 2;
	counts_in[0] = 2;
	counts_in[3] = (_oscillator ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = 2;
	counts_out[4] = (_oscillator ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_out = _polar_x.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	if ( _centering ) /* center ensemble */
		thrust::transform(
			state.begin(), state.end(),
			thrust::make_permutation_iterator(
				_center.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 / ensemble.get_size() ) ),
	        state.begin(), thrust::minus< enosc::scalar >() );

	ensemble.compute_polar( state, deriv );
	_polar_x.write( enosc::host_vector( polar.begin(), polar.end() ).data(), _datatype, dataspace_in, dataspace_out );
	_polar_dxdt.write( enosc::host_vector( deriv.begin(), deriv.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write mean funnel */
	dims_in[0] = 1;
	dims_in[3] = 1;
	counts_in[0] = 1;
	counts_in[3] = (_ensemble ? 1 : 0) * (_track_funnel ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = 1;
	counts_out[4] = (_ensemble ? 1 : 0) * (_track_funnel ? 1 : 0);
	dataspace_out = _funnel_mx.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	compute_funnel( deriv, ensemble.get_size() );
	_funnel_mx.write( enosc::host_vector( _funnel.begin(), _funnel.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write polar mean */
	dims_in[0] = 2;
	counts_in[0] = 2;
	counts_in[3] = (_ensemble ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = 2;
	counts_out[4] = (_ensemble ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_out = _polar_mx.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	ensemble.compute_mean( polar );
	_polar_mx.write( enosc::host_vector( mean.begin(), mean.end() ).data(), _datatype, dataspace_in, dataspace_out );

	ensemble.compute_mean( deriv );
	_polar_dmxdt.write( enosc::host_vector( mean.begin(), mean.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write raw mean (raw meanfield) */
	dims_in[0] = ensemble.get_dim();
	counts_in[0] = ensemble.get_dim();
	counts_in[3] = (_ensemble ? 1 : 0) * (_track_raw ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = ensemble.get_dim();
	counts_out[4] = (_ensemble ? 1 : 0) * (_track_raw ? 1 : 0);
	dataspace_out = _raw_mx.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	if ( _centering ) /* un-center ensemble */
		thrust::transform(
			state.begin(), state.end(),
			thrust::make_permutation_iterator(
				_center.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 / ensemble.get_size() ) ),
	        state.begin(), thrust::plus< enosc::scalar >() );

	ensemble.compute_mean( state );
	_raw_mx.write( enosc::host_vector( mean.begin(), mean.end() ).data(), _datatype, dataspace_in, dataspace_out );
	thrust::copy( mean.begin(), mean.end(), _tmp.begin() ); /* keep a backup of raw-mx */

	thrust::transform( /* re-compute derivative */
		state_next.begin(), state_next.end(),
		state.begin(),
		deriv.begin(), thrust::minus< enosc::scalar >() );

	ensemble.compute_mean( deriv );
	_raw_dmxdt.write( enosc::host_vector( mean.begin(), mean.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write polar meanfield */
	dims_in[0] = 2;
	counts_in[0] = 2;
	counts_in[3] = (_meanfield ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = 2;
	counts_out[4] = (_meanfield ? 1 : 0) * (_track_polar ? 1 : 0);
	dataspace_out = _polar_mf.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	if ( _centering ) /* re-center meanfield */
		thrust::transform(
			_tmp.begin(), _tmp.end(),
			_center.begin(),
	        _tmp.begin(), thrust::minus< enosc::scalar >() );

	ensemble.compute_polar( _tmp, mean ); /* use backup of raw-mx */
	_polar_mf.write( enosc::host_vector( polar.begin(), polar.end() ).data(), _datatype, dataspace_in, dataspace_out );
	_polar_dmfdt.write( enosc::host_vector( deriv.begin(), deriv.end() ).data(), _datatype, dataspace_in, dataspace_out );

		/* write meanfield funnel */
	dims_in[0] = 1;
	dims_in[3] = 1;
	counts_in[0] = 1;
	counts_in[3] = (_meanfield ? 1 : 0) * (_track_funnel ? 1 : 0);
	dataspace_in = H5::DataSpace( 4, dims_in );
	dataspace_in.selectHyperslab( H5S_SELECT_SET, counts_in, starts_in );

	counts_out[1] = 1;
	counts_out[4] = (_meanfield ? 1 : 0) * (_track_funnel ? 1 : 0);
	dataspace_out = _funnel_mf.getSpace();
	dataspace_out.selectHyperslab( H5S_SELECT_SET, counts_out, starts_out );

	compute_funnel( deriv, 1 );
	_funnel_mf.write( enosc::host_vector( _funnel.begin(), _funnel.end() ).data(), _datatype, dataspace_in, dataspace_out );

}

