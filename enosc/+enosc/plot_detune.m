function plot_detune( h5c, times, epsilons, betas, plotfile, mask )
% plot frequency detune
%
% PLOT_DETUNE( h5c, times, epsilons, betas, plotfile, mask=true )
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
	logger.tab( 'plot frequency detune (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	dmxdt = double( mean( h5read( h5c.filename, '/polar/dmxdt', fliplr( starts ), fliplr( counts ) ), 5 ) / h5c.dt );

	starts = [itimes(1), 2, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	dmfdt = double( mean( h5read( h5c.filename, '/polar/dmfdt', fliplr( starts ), fliplr( counts ) ), 5 ) / h5c.dt );

		% apply data mask
	if nargin >= 6
		dmxdt(~mask) = NaN;
		dmfdt(~mask) = NaN;
	else
		mask = true( size( squeeze( dmxdt ) ) );
	end

		% compute detune
	detune = dmfdt ./ dmxdt;

		% plot
	fig = style.figure();

	ncols = 64;
	colormap( style.gradient( ncols, style.color( 'warm', 0 ), style.color( 'cold', 0 ) ) );

	subplot( 2, 2, [1, 2] ); % detune
	title( sprintf( 'frequency detune (time: %s)', enosc.par2str( times ) ) );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( detune ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

	subplot( 2, 2, 3 ); % ensemble mean
	title( 'ensemble frequency' );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( dmxdt ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

	subplot( 2, 2, 4 ); % meanfield
	title( 'meanfield frequency' );
	xlabel( 'epsilon' );
	ylabel( 'beta' );
	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );
	imagesc( epsilons, betas, squeeze( dmfdt ), ...
		'AlphaDataMapping', 'none', 'AlphaData', double( mask ) );
	colorbar();

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

