function plot_raw( h5c, times, epsilons, betas, plotfile )
% plot raw trajectory
%
% PLOT_RAW( h5c, times, epsilons, betas, plotfile )
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
	counts = [numel( itimes ), h5c.dim, numel( iepsilons ), numel( ibetas ), h5c.oscillator];
	x = double( h5read( h5c.filename, '/raw/x', fliplr( starts ), fliplr( counts ) ) );

	starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
	counts = [numel( itimes ), h5c.dim, numel( iepsilons ), numel( ibetas ), h5c.ensemble];
	mx = double( h5read( h5c.filename, '/raw/mx', fliplr( starts ), fliplr( counts ) ) );

		% prepare plot
	fig = style.figure();

	title( sprintf( 'raw trajectory (time: %s, epsilon: %s, beta: %s)', ...
		enosc.par2str( times ), enosc.par2str( epsilons ), enosc.par2str( betas ) ) );

	xlabel( 'x' );
	ylabel( 'y' );
	zlabel( 'z' );

		% plot
	shades = linspace( 2, 0, numel( iepsilons ) * numel( ibetas ) );
	ishade = 1;

	for i = iepsilons
		for j = ibetas
			switch h5c.dim

				case 2 % two-dimensional

				case 3 % three-dimensional

					view( 20, 35 );

					if h5c.oscillator % oscillator
						plot3( ...
							squeeze( x(1, j-ibetas(1)+1, i-iepsilons(1)+1, 1, :) ), ...
							squeeze( x(1, j-ibetas(1)+1, i-iepsilons(1)+1, 2, :) ), ...
							squeeze( x(1, j-ibetas(1)+1, i-iepsilons(1)+1, 3, :) ), ...
							'Color', style.color( 'cold', shades(ishade) ) );
					end

					if h5c.ensemble % ensemble mean (raw meanfield)
						plot3( ...
							squeeze( mx(1, j-ibetas(1)+1, i-iepsilons(1)+1, 1, :) ), ...
							squeeze( mx(1, j-ibetas(1)+1, i-iepsilons(1)+1, 2, :) ), ...
							squeeze( mx(1, j-ibetas(1)+1, i-iepsilons(1)+1, 3, :) ), ...
							'Color', style.color( 'warm', shades(ishade) ) );
					end

				otherwise
					warning( 'invalid value: h5c.dim' );

			end
		end

		ishade = ishade + 1;
	end

		% done
	style.print( plotfile );

	delete( fig );

	logger.untab();
end

