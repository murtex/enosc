function fig_funnel( h5c, times, epsilons, betas, plotfile, mask )
% plot funnel indicator
%
% FIG_FUNNEL( h5c, times, epsilons, betas, plotfile, mask=true )
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

	if nargin < 3 || (~isempty( betas ) && ~isrow( betas )) || ~isnumeric( betas )
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
	logger.tab( 'plot funnel (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read funnel data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	mx = squeeze( double( abs( sum( h5read( h5c.filename, '/funnel/mx', fliplr( starts ), fliplr( counts ) ), 5 ) ) ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mf = squeeze( double( abs( sum( h5read( h5c.filename, '/funnel/mf', fliplr( starts ), fliplr( counts ) ), 5 ) ) ) );

	if nargin >= 6 % apply mask
		mx(~mask) = NaN;
		mf(~mask) = NaN;
	end

	total = max( mx, mf ); % composite funnel

		% plot
	fig = style.figure( ...
		'PaperPosition', enosc.tile( 6, 3 ), ...
		'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
		'defaultAxesNextPlot', 'add' ...
		);

	colormap( [1, 1, 1] ); % initialize nan-colormap

	subplot( 2, 2, [1, 2] );
	title( sprintf( 'composite funnel (time: %s)', enosc.par2str( times ) ) );
	enosc.plot_map2( total, epsilons, betas );

	subplot( 2, 2, 3 );
	title( 'ensemble funnel' );
	enosc.plot_map2( mx, epsilons, betas );
	
	subplot( 2, 2, 4 );
	title( 'meanfield funnel' );
	enosc.plot_map2( mf, epsilons, betas );

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

