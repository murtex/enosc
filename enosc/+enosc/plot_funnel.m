function plot_funnel( h5c, times, epsilons, betas, plotfile )
% plot funnel
%
% PLOT_FUNNEL( h5c, times, epsilons, betas, plotfile )
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

	if nargin < 3 || (~isempty( betas ) && ~isrow( betas )) || ~isnumeric( betas )
		error( 'invalid argument: betas' );
	end
	if isempty( betas )
		betas = [h5c.betas(1), h5c.betas(end)];
	end

	if nargin < 5 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot funnel (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	mx = double( abs( sum( h5read( h5c.filename, '/funnel/mx', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mf = double( abs( sum( h5read( h5c.filename, '/funnel/mf', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

		% normalize funnel data
	mxmax = max( mx(:) );
	if mxmax ~= 0
		mx = mx / mxmax;
	end
	mfmax = max( mf(:) );
	if mfmax ~= 0
		mf = mf / mfmax;
	end

	total = mx + mf;
	totalmax = max( total(:) );
	if totalmax ~= 0
		total = total / totalmax;
	end

		% plot
	fig = style.figure();

	if numel( epsilons ) == 1 && numel( betas ) > 1 % fixed epsilon

		subplot( 2, 2, [1, 2], 'YTickLabel', {} ); % total
		title( sprintf( 'total funnel (time: %s, epsilon: %s)', enosc.par2str( times ), enosc.par2str( epsilons ) ) );
		xlabel( 'beta' );
		ylabel( 'funnel' );
		xlim( [min( betas ), max( betas )] );
		ylim( [0, 1] );
		plot( betas, squeeze( total ), ...
			'Color', style.color( 'warm', 0 ) );

		subplot( 2, 2, 3, 'YTickLabel', {} ); % ensemble mean
		title( 'ensemble funnel' );
		xlabel( 'beta' );
		ylabel( 'funnel' );
		xlim( [min( betas ), max( betas )] );
		ylim( [0, 1] );
		plot( betas, squeeze( mx ), ...
			'Color', style.color( 'warm', 0 ) );

		subplot( 2, 2, 4, 'YTickLabel', {} ); % meanfield
		title( 'meanfield funnel' );
		xlabel( 'beta' );
		ylabel( 'funnel' );
		xlim( [min( betas ), max( betas )] );
		ylim( [0, 1] );
		plot( betas, squeeze( mf ), ...
			'Color', style.color( 'warm', 0 ) );
	
	elseif numel( epsilons ) > 1 && numel( betas ) == 1 % fixed beta

		subplot( 2, 2, [1, 2], 'YTickLabel', {} ); % total
		title( sprintf( 'total funnel (time: %s, beta: %s)', enosc.par2str( times ), enosc.par2str( betas ) ) );
		xlabel( 'epsilon' );
		ylabel( 'funnel' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [0, 1] );
		plot( epsilons, squeeze( total ), ...
			'Color', style.color( 'warm', 0 ) );

		subplot( 2, 2, 3, 'YTickLabel', {} ); % ensemble mean
		title( 'ensemble funnel' );
		xlabel( 'epsilon' );
		ylabel( 'funnel' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [0, 1] );
		plot( epsilons, squeeze( mx ), ...
			'Color', style.color( 'warm', 0 ) );

		subplot( 2, 2, 4, 'YTickLabel', {} ); % meanfield
		title( 'meanfield funnel' );
		xlabel( 'epsilon' );
		ylabel( 'funnel' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [0, 1] );
		plot( epsilons, squeeze( mf ), ...
			'Color', style.color( 'warm', 0 ) );
	
	elseif numel( epsilons ) > 1 && numel( betas ) > 1  % epsilon-beta-map

		colormap( style.gradient( 64, [1, 1, 1], style.color( 'warm', 0 ) ) );

		subplot( 2, 2, [1, 2] ); % total
		title( sprintf( 'total funnel (log) (time: %s)', enosc.par2str( times ) ) );
		xlabel( 'epsilon' );
		ylabel( 'beta' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [min( betas ), max( betas )] );
		imagesc( epsilons, betas, log( squeeze( total ) + eps ) );

		subplot( 2, 2, 3 ); % ensemble mean
		title( 'ensemble funnel (log)' );
		xlabel( 'epsilon' );
		ylabel( 'beta' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [min( betas ), max( betas )] );
		imagesc( epsilons, betas, log( squeeze( mx ) + eps ) );

		subplot( 2, 2, 4 ); % meanfield
		title( 'meanfield funnel (log)' );
		xlabel( 'epsilon' );
		ylabel( 'beta' );
		xlim( [min( epsilons ), max( epsilons )] );
		ylim( [min( betas ), max( betas )] );
		imagesc( epsilons, betas, log( squeeze( mf ) + eps ) );

	end

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

