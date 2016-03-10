/**
 * integrate.cu
 * 20150701
 *
 * integrate dynamical system
 */

	/* includes */
#include <unistd.h>

#include <xis/singleton.h>
#include <xis/logger.h>

#include <xis/factory.h>
#include <enosc/ensemble.h>
#include <enosc/roessler.h>
#include <enosc/roessler_mod.h>
#include <enosc/sakaguchi.h>
#include <enosc/sakaguchi_add.h>

#include <enosc/observer.h>
#include <enosc/hdf5.h>

#include <enosc/stepper.h>
#include <enosc/euler.h>
#include <enosc/heun.h>

	/* command line */
char const * _cl_config = NULL;
char const * _cl_include = NULL;
char const * _cl_output = NULL;

void cl_usage( char * cmd )
{
	std::cout << "usage: " << cmd << " [-h] -c config [-i include] [-o output]" << std::endl;
}

void cl_parse( int argc, char ** argv )
{

		/* proceed command line options */
	int optc;

	while ( (optc = getopt( argc, argv, "hc:i:o:" ) ) != -1 )
		switch ( optc ) {

			case '?': /* general */
				cl_usage( argv[0] );
				exit( 1 );
			case 'h':
				cl_usage( argv[0] );
				exit( 0 );

			case 'c': /* arguments */
				_cl_config = optarg;
				break;
			case 'i':
				_cl_include = optarg;
				break;
			case 'o':
				_cl_output = optarg;
				break;

		}

		/* check options */
	if ( _cl_config == NULL )
		throw std::runtime_error( "invalid value (cl_parse): _cl_config" );

	if ( _cl_output == NULL )
		throw std::runtime_error( "invalid value (cl_parse): _cl_output" );

}

	/* workflow */
libconfig::Config & _config = xis::Singleton< libconfig::Config >::instance();

xis::Logger & _logger = xis::Singleton< xis::Logger >::instance();

enosc::Ensemble * _ensemble = NULL;
enosc::Stepper * _stepper = NULL;
enosc::Observer * _observer = NULL;

void init()
{

		/* read configuration file */
	if ( _cl_include != NULL )
		_config.setIncludeDir( _cl_include );

	_config.readFile( _cl_config );

		/* configure logger */
	_logger.configure( _config, "logger" );

		/* initialize ensemble */
	xis::Factory< enosc::Ensemble > fac_ensemble; /* registration */

	fac_ensemble.enroll< enosc::Roessler >( "roessler" );
	fac_ensemble.enroll< enosc::RoesslerMod >( "roessler-mod" );
	fac_ensemble.enroll< enosc::Sakaguchi >( "sakaguchi" );
	fac_ensemble.enroll< enosc::SakaguchiAdd >( "sakaguchi-add" );

	std::string ensemble = _config.lookup( "ensemble/type" ); /* creation */
	_logger.tab() << "create ensemble (" << ensemble << ")...\n";

	_ensemble = fac_ensemble.create( ensemble );
	_ensemble->configure( _config, "ensemble" );
	_ensemble->init();

	_logger.untab();

		/* initialize stepper */
	xis::Factory< enosc::Stepper > fac_stepper; /* registration */

	fac_stepper.enroll< enosc::Euler >( "euler" );
	fac_stepper.enroll< enosc::Heun >( "heun" );

	std::string stepper = _config.lookup( "stepper/type" ); /* creation */
	_logger.tab() << "create stepper (" << stepper << ")...\n";

	_stepper = fac_stepper.create( stepper );
	_stepper->configure( _config, "stepper" );
	_stepper->init( *_ensemble );

	_logger.untab();

		/* initialize observer */
	xis::Factory< enosc::Observer > fac_observer; /* registration */

	fac_observer.enroll< enosc::HDF5 >( "hdf5" );

	std::string observer = _config.lookup( "observer/type" ); /* creation */
	_logger.tab() << "create observer (" << observer << ")...\n";

	_observer = fac_observer.create( observer );
	_observer->configure( _config, "observer" );
	_observer->init( *_ensemble, *_stepper, _cl_output );

	_logger.untab();

}

void exit()
{
}

void run()
{

		/* integrate and observe ensemble */
	enosc::host_vector const & times = _stepper->get_times();
	unsigned int steps = times.size() - 1;

	if ( steps == 0 ) /* initial state only */
		_observer->observe( *_ensemble, 0, times[0] );

	else { /* continuous integration */
		_logger.progress( steps, steps ) << "integrate ensemble...\n";
		for ( unsigned int i = 0; i < steps; ++i ) {
			_logger.progress( i, steps );

			if ( i == 0 ) /* initial state */
				_observer->observe( *_ensemble, i, times[i] );

			_stepper->integrate( *_ensemble, i ); /* integrated state */
			_observer->observe( *_ensemble, i+1, times[i+1] );

			_ensemble->swap(); /* swap buffers */

		}
	}

}

	/* main */
int main( int argc, char ** argv )
{

		/* parse command line */
	cl_parse( argc, argv );

		/* proceed workflow */
	init();
	run();
	exit();

	_logger.log() << "done.\n";

	return 0;
}

