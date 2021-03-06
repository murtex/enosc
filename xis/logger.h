/**
 * logger.h
 * 20150701
 *
 * hierarchical logger
 */
#ifndef XIS_LOGGER_H
#define XIS_LOGGER_H

	/* includes */
#include <xis/config.h>

#include <iostream>
#include <vector>
#include <ctime>
#include <sstream>

	/* interface */
namespace xis
{

		/* logger */
	class Logger : public xis::Config
	{

			/* con/destruction */
		public:

			Logger();
			~Logger();

			/* configuration */
		private:

			unsigned int _hierarchy_max; /* maximum hierarchical level */
			unsigned int _aggregate_max; /* maximum aggregation */

		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* timing */
		private:

			std::vector< std::clock_t > _clocks; /* hierarchy clocks */

			/* buffering */
		public:

			void flush() { std::cout.flush(); }

			/* logging */
		private:

			unsigned int _hierarchy_cur; /* current hierarchical level */
			unsigned int _hierarchy_pend; /* pending hierarchical level */

		public:

			Logger & tab();
			void untab();

			Logger & log();

			template< typename T >
			Logger & operator<<( T const & v )
			{

					/* safeguard */
				if ( _hierarchy_cur > _hierarchy_max )
					return *this;

					/* logging */
				std::cout << v;

				return *this;
			}

			Logger & operator<<( bool const & v )
			{

					/* safeguard */
				if ( _hierarchy_cur > _hierarchy_max )
					return *this;

					/* logging */
				if ( v )
					std::cout << "true";
				else
					std::cout << "false";

				return *this;
			}

			template< typename T >
			Logger & operator<<( std::vector< T > const & v )
			{

					/* safeguard */
				if ( _hierarchy_cur > _hierarchy_max )
					return *this;

					/* logging */
				std::cout << "[";

				typename std::vector< T >::size_type n = v.size();
				for ( typename std::vector< T >::size_type i = 0; i < n; ++i ) {

					if ( i < _aggregate_max ) {
						std::cout << v[i];

						if ( i < n-1 )
							std::cout << ", ";
					}

					else {
						std::cout << "..(" << v.size() << ")";
						break;
					}

				}

				std::cout << "]";

				return *this;
			}

			/* progression */
		public:

			Logger & progress2( unsigned int cur, unsigned int max );
			Logger & progress( unsigned int cur, unsigned int max );

	};

}

#endif /* XIS_LOGGER_H */

