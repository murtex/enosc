/**
 * types.cu
 * 20150705
 *
 * data types
 */

	/* includes */
#include "types.h"

	/* logging */
xis::Logger & operator<<( xis::Logger & logger, enosc::host_vector const & v )
{

		/* convert to standard container */
	std::vector< enosc::scalar > sv( v.begin(), v.end() );

		/* logging */
	return logger << sv;
}

xis::Logger & operator<<( xis::Logger & logger, enosc::device_vector const & v )
{

		/* convert to standard container */
	std::vector< enosc::scalar > sv( v.begin(), v.end() );

		/* logging */
	return logger << sv;
}

