function plot_order( h5c, times, epsilons, betas, plotfile, mask )
% plot synchronization order
%
% PLOT_ORDER( h5c, times, epsilons, betas, plotfile, mask=true )
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
	logger.tab( 'plot synchronization order (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	mx = double( mean( h5read( h5c.filename, '/polar/mx', fliplr( starts ), fliplr( counts ) ), 5 ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mf = double( mean( h5read( h5c.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ), 5 ) );

		% apply data mask
	if nargin >= 6
		mx(~mask) = NaN;
		mf(~mask) = NaN;
	else
		mask = true( size( squeeze( mx ) ) );
	end

		% compute order
	order = mf ./ mx;

		% plot
	fig = style.figure();

	ncols = 64;
	colormap( style.gradient( ncols, style.color( 'cold', +2 ), style.color( 'cold', -2 ) ) );

	subplot( 2, 2, [1, 2] ); % order
	title( sprintf( 'synchronization order (time: %s)', enosc.par2str( times ) ) );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( order ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

	subplot( 2, 2, 3 ); % ensemble mean
	title( 'ensemble amplitude' );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( mx ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

	subplot( 2, 2, 4 ); % meanfield
	title( 'meanfield amplitude' );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( mf ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

