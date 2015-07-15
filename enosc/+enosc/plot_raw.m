function plot_raw( datafile, epsilon, beta, plotfile )
% plot raw trajectory
%
% PLOT_RAW( datafile, plotfile )
%
% INPUT
% datafile : data filename (row char)
% plotfile : plot filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( datafile ) || ~ischar( datafile ) || exist( datafile, 'file' ) ~= 2
		error( 'invalid argument: datafile' );
	end

	if nargin < 2 || ~isrow( plotfile ) || ~ischar( plotfile )
		error( 'invalid argument: plotfile' );
	end

	logger = xis.hLogger.instance();
	logger.tab( 'plot raw (''%s'')...', plotfile );

	style = xis.hStyle.instance();

		% prepare data
	epsilons = h5read( datafile, '/epsilons' ); % coupling
	[~, iepsilon] = min( abs( epsilons - epsilon ) );
	betas = h5read( datafile, '/betas' );
	[~, ibeta] = min( abs( betas - beta ) );

	times = h5read( datafile, '/times' ); % stepping
	dt = h5read( datafile, '/dt' );

	x = squeeze( h5read( datafile, '/raw/x', ... % raw
		fliplr( [1, 1, iepsilon, ibeta, 1] ), ...
		fliplr( [numel( times ), 3, 1, 1, 1] ) ) );

	mx = squeeze( h5read( datafile, '/raw/mx', ...
		fliplr( [1, 1, iepsilon, ibeta, 1] ), ...
		fliplr( [numel( times ), 3, 1, 1, 1] ) ) );

		% plot
	fig = style.figure();

	xlabel( 'x' );
	ylabel( 'y' );
	zlabel( 'z' );

	view( 30, 30 );
	plot3( x(1, :), x(2, :), x(3, :), ...
		'Color', style.color( 'cold', 0 ) );
	plot3( mx(1, :), mx(2, :), mx(3, :), ...
		'Color', style.color( 'warm', 0 ) );

	style.print( plotfile );

	delete( fig );

	logger.untab();
end

