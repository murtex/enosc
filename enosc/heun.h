/**
 * euler.h
 * 20160310
 *
 * heun stepper
 */
#ifndef ENOSC_HEUN_H
#define ENOSC_HEUN_H

	/* includes */
#include <enosc/stepper.h>

	/* interface */
namespace enosc
{

		/* stepper */
	class Heun : public enosc::Stepper
	{

			/* con/destruction */
		public:

			Heun() {}
			~Heun() {}

			/* configuration */
		public:

			void configure( libconfig::Config const & config, std::string const & groupname );

			/* integration */
		private:

			enosc::device_vector _tmp1; /* temporary buffers */
			enosc::device_vector _tmp2;

		public:

			void init( enosc::Ensemble const & ensemble );

			void integrate( enosc::Ensemble & ensemble, unsigned int step );

	};

}

#endif /* ENOSC_HEUN_H */


