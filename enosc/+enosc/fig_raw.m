function fig_raw( h5c, times, epsilons, betas, plotfile )
% plot raw trajectory
%
% FIG_RAW( h5c, times, epsilons, betas, plotfile )
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
	logger.tab( 'plot raw trajectory (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% snap parameters
	[times, itimes] = enosc.parsnap( h5c.times, times );
	[epsilons, iepsilons] = enosc.parsnap( h5c.epsilons, epsilons );
	[betas, ibetas] = enosc.parsnap( h5c.betas, betas );

		% read data
	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), h5c.dim, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	x = double( h5read( h5c.filename, '/raw/x', fliplr( starts ), fliplr( counts ) ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), h5c.dim, numel( iepsilons ), numel( ibetas ), h5c.meanfield];
	mx = double( h5read( h5c.filename, '/raw/mx', fliplr( starts ), fliplr( counts ) ) );

	x = squeeze( x );
	mx = squeeze( mx );

		% plot
	fig = style.figure();

	title( sprintf( 'raw trajectory (time: %s, epsilon: %s, beta: %s)', ...
		enosc.par2str( times ), enosc.par2str( epsilons ), enosc.par2str( betas ) ) );

	view( 30, 35 );

	plot3( x(1, :), x(2, :), x(3, :), ...
		'Color', style.color( 'cold', 0 ) );
	plot3( mx(1, :), mx(2, :), mx(3, :), ...
		'Color', style.color( 'warm', 0 ) );

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

