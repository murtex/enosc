/**
 * roessler.cu
 * 20150703
 *
 * roessler ensemble
 */

	/* includes */
#include "roessler.h"

#include <xis/singleton.h>
#include <xis/logger.h>

#include <enosc/kernels.h>

	/* con/destruction */
enosc::Roessler::Roessler()
{

		/* initialize configuration */
	_dim = 3;

	_a = 0.15;
	_b = 0.4;
	_c = 8.5;

}

	/* configuration */
void enosc::Roessler::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Ensemble::configure( config, groupname );

		/* parse group settings */
	std::string settingname = groupname + "/a";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _a );

	settingname = groupname + "/b";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _b );

	settingname = groupname + "/c";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _c );

		/* logging */
	xis::Logger & logger = xis::Singleton< xis::Logger >::instance();

	logger.log() << "a: " << _a << "\n";
	logger.log() << "b: " << _b << "\n";
	logger.log() << "c: " << _c << "\n";

}

	/* phase space */
void enosc::Roessler::init()
{

		/* base call */
	enosc::Ensemble::init();

		/* prepare random state */
	enosc::host_vector rs( _size );
	enosc::host_vector phis( _size );
	enosc::host_vector zs( _size );

	for ( unsigned int i = 0; i < _size; ++i ) {
		rs[i] = rand() / (double) RAND_MAX * 5 + 7.5; /* [7.5..12.5] */
		phis[i] = rand() / (double) (RAND_MAX-1) * 2*M_PI; /* [0..2pi) */
		zs[i] = rand() / (double) RAND_MAX * 0.5; /* [0..0.5] */
	}

		/* transfer random state */
	enosc::device_vector drs( rs );
	enosc::device_vector dphis( phis );
	enosc::device_vector dzs( zs );

	thrust::for_each_n(
		thrust::make_zip_iterator( thrust::make_tuple(

			thrust::make_permutation_iterator( /* cylinder input */
				drs.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 % _size ) ),
			thrust::make_permutation_iterator(
				dphis.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 % _size ) ),
			thrust::make_permutation_iterator(
				dzs.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 % _size ) ),

			_state.begin(), /* cartesian output */
			_state.begin() + _epsilons.size() * _betas.size() * _size,
			_state.begin() + 2 * _epsilons.size() * _betas.size() * _size ) ),

		_epsilons.size() * _betas.size() * _size, enosc::CylinderToCartesian() );

}

	/* ode */
bool enosc::Roessler::compute_deriv_det( enosc::device_vector const & state, enosc::scalar time )
{

		/* safeguard */
	if ( state.size() != _state.size() )
		throw std::runtime_error( "invalid argument: enosc::Roessler::compute_deriv_det, state" );

		/* compute ode */
	compute_mean( state );

	thrust::for_each_n(
		thrust::make_zip_iterator( thrust::make_tuple(

			state.begin(), /* state input */
			state.begin() + _epsilons.size() * _betas.size() * _size,
			state.begin() + 2 * _epsilons.size() * _betas.size() * _size,

			thrust::make_permutation_iterator( /* coupling input */
				_epsilons.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					(thrust::placeholders::_1 / (_betas.size() * _size)) % _epsilons.size() ) ),
			thrust::make_permutation_iterator(
				_betas.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
                    (thrust::placeholders::_1 / _size) % _betas.size() ) ),

            thrust::make_permutation_iterator( /* meanfield input */
				_mean.begin(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 / _size ) ),
			thrust::make_permutation_iterator(
				_mean.begin() + _epsilons.size() * _betas.size(),
				thrust::make_transform_iterator(
					thrust::counting_iterator< unsigned int >( 0 ),
					thrust::placeholders::_1 / _size ) ),

			_deriv.begin(), /* derivative output */
			_deriv.begin() + _epsilons.size() * _betas.size() * _size,
			_deriv.begin() + 2 * _epsilons.size() * _betas.size() * _size ) ),

		_epsilons.size() * _betas.size() * _size, enosc::RoesslerODE( _a, _b, _c ) );

	return true;
}

