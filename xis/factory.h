/**
 * factory.h
 * 20150703
 *
 * abstract factory pattern
 *
 * TODO: template<class> class std::auto_ptr’ is deprecated
 */
#ifndef XIS_FACTORY_H
#define XIS_FACTORY_H

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

	/* includes */
#include <map>
#include <memory>

	/* interface */
namespace xis
{

		/* default creator */
	template< typename T, typename S >
	std::auto_ptr< T > _default_creator()
	{
		//return std::move( std::unique_ptr< T >( new S ) );
		return std::auto_ptr< T >( new S );
	}

		/* factory */
	template< typename T >
	class Factory
	{

			/* registration */
		private:

			typedef std::auto_ptr< T > (*_creator)();

			std::map< std::string const, _creator > _creators;

		public:

			template< typename S >
			void enroll( std::string const & id )
			{
				_creators[id] = &_default_creator< T, S >;
			}

			/* creation */
		public:

			T * create( std::string const & id )
			{

					/* safeguard */
				if ( _creators.find( id ) == _creators.end() )
					throw std::runtime_error( "invalid argument: xis::Factory::create, id" );

					/* creation */
				return _creators[id]().release();
			}

	};

}

#pragma GCC diagnostic pop

#endif /* XIS_FACTORY_H */

