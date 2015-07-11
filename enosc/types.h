/**
 * types.h
 * 20150705
 *
 * data types
 */
#ifndef ENOSC_TYPES_H
#define ENOSC_TYPES_H

	/* includes */
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <thrust/system/cpp/vector.h>
#include <thrust/system/omp/vector.h>
#include <thrust/system/cuda/vector.h>
#include <thrust/system/tbb/vector.h>

#include <xis/logger.h>

	/* interface */
namespace enosc
{

	typedef float scalar;

	typedef thrust::host_vector< scalar > host_vector;
	typedef thrust::cuda::vector< scalar > device_vector;

}

	/* logging */
xis::Logger & operator<<( xis::Logger & logger, enosc::host_vector const & v );
xis::Logger & operator<<( xis::Logger & logger, enosc::device_vector const & v );

#endif /* ENOSC_TYPES_H */

