function fig_acorr( h5c, times, epsilons, betas, plotfile )
% plot autocorrelation
%
% FIG_ACORR( h5c, times, epsilons, betas, plotfile )
%
% INPUT
% h5c : data container (scalar object)
% times : stepping time range (row numeric)
% epsilons : epsilon coupling range (row numeric)
% betas : beta coupling range (row numeric)
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

	if nargin < 5 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot autocorrelation (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% prepare white noise

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	x = squeeze( double( h5read( h5c.filename, '/polar/x', fliplr( starts ), fliplr( counts ) ) ) );

	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	dxdt = squeeze( double( h5read( h5c.filename, '/polar/dxdt', fliplr( starts ), fliplr( counts ) ) ) ) / h5c.dt;

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mf = squeeze( double( h5read( h5c.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ) ) );

	wn = wgn( numel( x ), 1, 0 ); % white noise
	order = mf ./ x; % order parameter

	awn = autocorr( wn, numel( wn )-1 ); % autocorrelation
	aorder = autocorr( order, numel( order )-1 );
	adxdt = autocorr( dxdt, numel( dxdt )-1 );

		% plot
	fig = style.figure( ...
		'PaperPosition', enosc.tile( 6, 2 ), ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on' ...
		);

	semilogx( awn, 'Color', style.color( 'neutral', 0 ), 'DisplayName', 'white noise' );
	hold on
	%semilogx( aorder, 'Color', style.color( 'neutral', +2 ), 'DisplayName', 'order parameter' );
	semilogx( adxdt, 'Color', style.color( 'neutral', +2 ), 'DisplayName', 'oscillator' );

	title( sprintf( 'frequency autocorrelation (epsilon: %s, beta/pi: %s)', enosc.par2str( epsilons ), enosc.par2str( betas ) ) );

	xlabel( 'time lag' );
	ylabel( 'autocorrelation' );

	xlim( [1, numel( awn )] );

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

