/**
 * singleton.h
 * 20150701
 *
 * singleton pattern
 */
#ifndef XIS_SINGLETON_H
#define XIS_SINGLETON_H

	/* interface */
namespace xis
{

		/* singleton */
	template< typename T > class Singleton
	{

			/* con/destruction */
		private:

			Singleton();
			Singleton( Singleton const & );
			Singleton & operator=( Singleton const & );

			~Singleton();

			/* instantiation */
		public:

			static T & instance()
			{
				static T si; /* static instance */
				return si;
			}

	};

}

#endif /* XIS_SINGLETON_H */

