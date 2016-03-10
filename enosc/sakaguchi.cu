/**
 * sakaguchi.cu
 * 20150703
 *
 * sakaguchi ensemble
 */

	/* includes */
#include "sakaguchi.h"

#include <xis/singleton.h>
#include <xis/logger.h>

#include <enosc/kernels.h>

	/* con/destruction */
enosc::Sakaguchi::Sakaguchi()
{

		/* initialize configuration */
	_dim = 2;
	_fpolar = true;

}

	/* configuration */
void enosc::Sakaguchi::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* base call */
	enosc::Ensemble::configure( config, groupname );

}

	/* phase space */
void enosc::Sakaguchi::init()
{

		/* base call */
	enosc::Ensemble::init();

		/* prepare random state */
	enosc::host_vector rs( _size );
	enosc::host_vector phis( _size );

	for ( unsigned int i = 0; i < _size; ++i ) {
		rs[i] = 1; /* const */
		phis[i] = rand() / (double) (RAND_MAX-1) * 2*M_PI; /* [0..2pi) */
	}

		/* transfer random state */
	enosc::device_vector drs( rs );
	enosc::device_vector dphis( phis );

	thrust::copy_n( /* amplitudes */
		thrust::make_permutation_iterator(
			drs.begin(),
			thrust::make_transform_iterator(
				thrust::counting_iterator< unsigned int >( 0 ),
				thrust::placeholders::_1 % _size ) ),
		_epsilons.size() * _betas.size() * _size, 
		_state.begin() );

	thrust::copy_n( /* phases */
		thrust::make_permutation_iterator(
			dphis.begin(),
			thrust::make_transform_iterator(
				thrust::counting_iterator< unsigned int >( 0 ),
				thrust::placeholders::_1 % _size ) ),
		_epsilons.size() * _betas.size() * _size, 
		_state.begin() + _epsilons.size() * _betas.size() * _size );

}

	/* ode */
bool enosc::Sakaguchi::compute_deriv_det( enosc::device_vector const & state, enosc::scalar time )
{

		/* safeguard */
	if ( state.size() != _state.size() )
		throw std::runtime_error( "invalid argument (enosc::Sakaguchi::compute_deriv_det): state" );

		/* compute ode */
	compute_mean( state );

	thrust::for_each_n(
		thrust::make_zip_iterator( thrust::make_tuple(

			state.begin(), /* state input */
			state.begin() + _epsilons.size() * _betas.size() * _size,

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
			_deriv.begin() + _epsilons.size() * _betas.size() * _size ) ),

		_epsilons.size() * _betas.size() * _size, enosc::SakaguchiODE() );

	return true;
}

