function fig_polar( h5c, times, epsilons, betas, fmf, plotfile )
% plot polar trajectory
%
% FIG_POLAR( h5c, times, epsilons, betas, fmf, plotfile )
%
% INPUT
% h5c : data container (scalar object)
% times : stepping time range (row numeric)
% epsilons : epsilon coupling range (row numeric)
% betas : beta coupling range (row numeric)
% fmf : meanfield flag (scalar logical)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isscalar( h5c ) || ~isa( h5c, 'enosc.hH5C' )
		error( 'invalid argument: h5c' );
	end

	if nargin < 2 || (~isempty( times ) && ~isrow( times )) || ~isnumeric( times )
		error( 'invalid argument: times' );
	end
	if isempty( times )
		times = [h5c.times(1), h5c.times(end)];
	end

	if nargin < 3 || (~isempty( epsilons ) && ~isrow( epsilons )) || ~isnumeric( epsilons )
		error( 'invalid argument: epsilons' );
	end
	if isempty( epsilons )
		epsilons = [h5c.epsilons(1), h5c.epsilons(end)];
	end

	if nargin < 4 || (~isempty( betas ) && ~isrow( betas )) || ~isnumeric( betas )
		error( 'invalid argument: betas' );
	end
	if isempty( betas )
		betas = [h5c.betas(1), h5c.betas(end)];
	end

	if nargin < 5 || ~isscalar( fmf ) || ~islogical( fmf )
		error( 'invalid argument: fmf' );
	end

	if nargin < 6 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot polar trajectory (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 2, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	x = squeeze( double( h5read( h5c.filename, '/polar/x', fliplr( starts ), fliplr( counts ) ) ) );
	mx = squeeze( double( h5read( h5c.filename, '/polar/mx', fliplr( starts ), fliplr( counts ) ) ) );
	dxdt = squeeze( double( h5read( h5c.filename, '/polar/dxdt', fliplr( starts ), fliplr( counts ) ) ) );
	dmxdt = squeeze( double( h5read( h5c.filename, '/polar/dmxdt', fliplr( starts ), fliplr( counts ) ) ) );

	if fmf
		starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
		counts = [numel( itimes ), 2, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
		mf = squeeze( double( h5read( h5c.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ) ) );
		dmfdt = squeeze( double( h5read( h5c.filename, '/polar/dmfdt', fliplr( starts ), fliplr( counts ) ) ) );
	end

		% plot
	fig = style.figure();

	subplot( 2, 2, [1, 3] ); % polar

	title( sprintf( 'polar trajectory (time: %s, epsilon: %s, beta: %s)', ...
		enosc.par2str( times ), enosc.par2str( epsilons ), enosc.par2str( betas ) ) );

	h = polar( x(2, :), x(1, :) );
	set( h, 'Color', style.color( 'neutral', +2 ) );
	if fmf
		h = polar( mf(2, :), mf(1, :) );
		set( h, 'Color', style.color( 'warm', +2 ) );
	end

	subplot( 2, 2, 2 ); % amplitude

	xlabel( 'time ' );
	ylabel( 'amplitude' );

	plot( times-times(1), x(1, :), 'Color', style.color( 'neutral', +2 ), 'DisplayName', 'oscillator' );
	if fmf
		plot( times-times(1), mf(1, :), 'Color', style.color( 'warm', +2 ), 'DisplayName', 'meanfield' );
	end
	plot( times-times(1), mx(1, :), 'Color', style.color( 'cold', +2 ), 'DisplayName', 'ensemble' );
	if fmf
		plot( xlim(), mean( mf(1, :) ) * [1, 1], 'Color', style.color( 'warm', 0 ), 'DisplayName', 'avg. meanfield' );
	end
	plot( xlim(), mean( mx(1, :) ) * [1, 1], 'Color', style.color( 'cold', 0 ), 'DisplayName', 'avg. ensemble' );

	subplot( 2, 2, 4 ); % frequency

	xlabel( 'time' );
	ylabel( 'frequency' );

	plot( times-times(1), dxdt(2, :), 'Color', style.color( 'neutral', +2 ), 'DisplayName', 'oscillator' );
	if fmf
		plot( times-times(1), dmfdt(2, :), 'Color', style.color( 'warm', +2 ), 'DisplayName', 'meanfield' );
	end
	plot( times-times(1), dmxdt(2, :), 'Color', style.color( 'cold', +2 ), 'DisplayName', 'ensemble' );
	if fmf
		plot( xlim(), mean( dmfdt(2, :) ) * [1, 1], 'Color', style.color( 'warm', 0 ), 'DisplayName', 'avg. meanfield' );
	end
	plot( xlim(), mean( dmxdt(2, :) ) * [1, 1], 'Color', style.color( 'cold', 0 ), 'DisplayName', 'avg. ensemble' );

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end


