function fig_phase( h5c, times, epsilons, betas, fmf, plotfile )
% plot phase
%
% FIG_PHASE( h5c, times, epsilons, betas, fmf, plotfile )
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
	logger.tab( 'plot phase (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	x = squeeze( double( h5read( h5c.filename, '/polar/x', fliplr( starts ), fliplr( counts ) ) ) );

	if fmf
		starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
		counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
		mf = squeeze( double( h5read( h5c.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ) ) );
	end

	while x(1) > 2*pi % unwrap phase
		x = x - 2*pi;
	end
	x = unwrap( x );

	if fmf
		while mf(1) > 2*pi
			mf = mf - 2*pi;
		end
		mf = unwrap( mf );
	end

		% plot
	fig = style.figure( ...
		'PaperPosition', enosc.tile( 6, 2 ), ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
		'defaultAxesNextPlot', 'add' ...
		);

	title( sprintf( 'phase (epsilon: %s, beta: %s)', enosc.par2str( epsilons ), enosc.par2str( betas ) ) );

	xlabel( 'time' );
	ylabel( 'phase in 2pi' );

	xlim( [0, times(end)-times(1)] );

	plot( times-times(1), x / (2*pi), 'Color', style.color( 'neutral', +2 ), 'DisplayName', 'oscillator' );

	if fmf
		plot( times-times(1), mf / (2*pi), 'Color', style.color( 'warm', +2 ), 'DisplayName', 'oscillator' );
	end

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

