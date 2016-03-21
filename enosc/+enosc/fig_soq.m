function fig_soq( h5c, times, epsilons, betas, plotfile, mask )
% plot soq
%
% FIG_SOQ( h5c, times, epsilons, betas, plotfile, mask=true )
%
% INPUT
% h5c : data container (scalar object)
% times : stepping time range (row numeric)
% epsilons : epsilon coupling range (row numeric)
% betas : beta coupling range (row numeric)
% plotfile : plot filename (row char)
% mask : data mask (matrix logical)

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

	if nargin >= 6 && ~ismatrix( mask ) && ~islogical( mask )
		error( 'invalid argument: mask' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot soq (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	mx = squeeze( double( mean( h5read( h5c.filename, '/polar/mx', fliplr( starts ), fliplr( counts ) ), 5 ) ) );
	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	dmxdt = squeeze( double( mean( h5read( h5c.filename, '/polar/dmxdt', fliplr( starts ), fliplr( counts ) ), 5 ) / h5c.dt ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mf = squeeze( double( mean( h5read( h5c.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ), 5 ) ) );
	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	dmfdt = squeeze( double( mean( h5read( h5c.filename, '/polar/dmfdt', fliplr( starts ), fliplr( counts ) ), 5 ) / h5c.dt ) );

	mmx = mx; % masked data
	mdmxdt = dmxdt;
	mmf = mf;
	mdmfdt = dmfdt;

	if nargin >= 6
		mmx(~mask) = NaN;
		mdmxdt(~mask) = NaN;
		mmf(~mask) = NaN;
		mdmfdt(~mask) = NaN;
	end

	order = mf ./ mx; % order parameter
	detune = dmfdt - dmxdt; % frequency detune

		% plot
	fig = style.figure( ...
		'PaperPosition', enosc.tile( 6, 4 ), ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
		'defaultAxesNextPlot', 'add' ...
		);

	subplot( 2, 1, 1 ); % amplitude
	title( sprintf( 'SOQ (beta/pi: %s)', enosc.par2str( betas ) ) );

	xlabel( 'epsilon' );
	ylabel( 'amplitude' );

	xlim( [epsilons(1), epsilons(end)] );

	plot( epsilons, mx, 'Color', style.color( 'cold', 0 ), 'LineStyle', '-.' );
	plot( epsilons, mmx, 'Color', style.color( 'cold', 0 ), 'DisplayName', 'avg. ensemble' );
	plot( epsilons, mf, 'Color', style.color( 'warm', 0 ), 'LineStyle', '-.' );
	plot( epsilons, mmf, 'Color', style.color( 'warm', 0 ), 'DisplayName', 'avg. mean field' );

	set( gca(), 'YLim', [0, get( gca(), 'YLim') * [0; 1]]);

	subplot( 2, 1, 2 ); % frequency

	xlabel( 'epsilon' );
	ylabel( 'frequency' );

	xlim( [epsilons(1), epsilons(end)] );

	plot( epsilons, dmxdt, 'Color', style.color( 'cold', 0 ), 'LineStyle', '--' );
	plot( epsilons, mdmxdt, 'Color', style.color( 'cold', 0 ), 'DisplayName', 'avg. ensemble' );
	plot( epsilons, dmfdt, 'Color', style.color( 'warm', 0 ), 'LineStyle', '--' );
	plot( epsilons, mdmfdt, 'Color', style.color( 'warm', 0 ), 'DisplayName', 'avg. mean field' );

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end


