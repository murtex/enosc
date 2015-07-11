/**
 * logger.cpp
 * 20150701
 *
 * hierarchical logger
 */

	/* includes */
#include "logger.h"

#include <limits>
#include <cmath>

	/* con/destruction */
xis::Logger::Logger()
{

		/* initialize configuration */
	_hierarchy_max = std::numeric_limits< unsigned int >::max();
	_aggregate_max = std::numeric_limits< unsigned int >::max();

		/* intialize timing */
	_clocks.resize( 1 );
	_clocks[0] = clock();

		/* initialize logging */
	_hierarchy_cur = 0;
	_hierarchy_pend = 0;

}

xis::Logger::~Logger()
{
}

	/* configuration */
void xis::Logger::configure( libconfig::Config const & config, std::string const & groupname )
{

		/* parse group settings */
	std::string settingname = groupname + "/hierarchy_max";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _hierarchy_max );

	settingname = groupname + "/aggregate_max";
	if ( config.exists( settingname ) )
		config.lookupValue( settingname, _aggregate_max );

}

	/* logging */
xis::Logger & xis::Logger::tab()
{

		/* safeguard */
	if ( _hierarchy_pend == std::numeric_limits< unsigned int >::max() )
	    throw std::runtime_error( "invalid value: xis::Logger::_hierarchy_pend" );

		/* increase hierarchical level */
	log();

	_hierarchy_pend++; /* level */

	if ( _clocks.size() < _hierarchy_pend+1 ) /* timing */
		_clocks.resize( _hierarchy_pend+1 );

	_clocks[_hierarchy_pend] = clock();

	return *this;
}

void xis::Logger::untab()
{

		/* safeguard */
	if ( _hierarchy_pend == 0 )
	    throw std::runtime_error( "invalid value: xis::Logger::_hierarchy_pend" );

		/* log hierarchy timing */
	double t = (clock() - _clocks[_hierarchy_pend]) / (double) CLOCKS_PER_SEC;

	if ( t > 10 ) {

		std::ostringstream ts;

		/*ts.setf( std::ios::right, std::ios::adjustfield );*/
		ts.setf( std::ios::fixed, std::ios::floatfield );

		/*ts.fill( ' ' );
		 *ts.width( 10 );*/
		ts.precision( 1 );

		ts << t;

		log() << "(" << ts.str() << ")\n";

	}

		/* decrease hierarchical level */
	_hierarchy_pend--;

}

xis::Logger & xis::Logger::log()
{

		/* safeguard */
	_hierarchy_cur = _hierarchy_pend;

	if ( _hierarchy_cur > _hierarchy_max )
		return *this;

		/* set timing */
	double t = (clock() - _clocks[0]) / (double) CLOCKS_PER_SEC;

	std::ostringstream ts;

	ts.setf( std::ios::right, std::ios::adjustfield );
	ts.setf( std::ios::fixed, std::ios::floatfield );

	ts.fill( ' ' );
	ts.width( 10 );
	ts.precision( 3 );

	ts << t;

		/* log header */
	std::cout << "[" << ts.str() << "]";
	std::cout << " ";

	for ( unsigned int i = 0; i < _hierarchy_cur; ++i )
		std::cout << "..";

	return *this;
}

	/* progression */
xis::Logger & xis::Logger::progress2( unsigned int cur, unsigned int max )
{

		/* start progression */
	static unsigned int decile_prev;

	if ( cur == 0 ) {
		if ( max == 0 )
			tab();
		else {
			log() << "0%..";
			flush();
		}

		decile_prev = 0;
	}

		/* continue/stop progression */
	if ( cur < max ) {

			/* continue */
		unsigned int decile_cur = max > 1 ? floor( 10 * cur / (double) (max-1) ) : 10;

		for ( unsigned int i = decile_prev; i < decile_cur; ++i ) {

			*this << 10*(i+1) << "%";

			if ( i+1 < 10 )
				*this << "..";
			else
				*this << "\n";
		}

		if ( decile_prev < decile_cur )
			flush();

		decile_prev = decile_cur;

			/* stop */
		if ( cur == max-1 )
			untab();

	}

	return *this;
}

xis::Logger & xis::Logger::progress( unsigned int cur, unsigned int max )
{

		/* start progression */
	static unsigned int decile_prev;

	if ( cur == max ) {
		tab();
		flush();

		decile_prev = 0;
	}

		/* continue/stop progression */
	else if ( cur < max ) {

			/* always log initial decile */
		if ( decile_prev == 0 ) {
			log() << "0%..";
			flush();

			decile_prev = 1;
		}

			/* increasing deciles */
		unsigned int decile_cur = floor( 10.0 * cur / max ) + 1; /* [1..10] ~ [0%..90%]*/

		if ( decile_prev != decile_cur ) {
			for ( unsigned int i = decile_prev; i < decile_cur; ++i )
				*this << 10*i << "%..";
			flush();

			decile_prev = decile_cur;
		}

			/* stop logging */
		if ( cur == max-1 ) {
			for ( unsigned int i = decile_cur; i < 10; ++i )
				*this << 10*i << "%..";

			*this << "100%\n";
			untab();
			flush();
		}

	}

	return *this;
}

