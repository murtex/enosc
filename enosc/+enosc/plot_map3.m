function plot_map3( data, epsilons, betas, cval )
% plot three-color gradient map
%
% PLOT_MAP3( data, epsilons, betas, cval )
%
% INPUT
% data : map data (matrix numeric)
% epsilons : epsilon coupling values (row numeric)
% betas : beta coupling values (row numeric)
% cval : central data value (scalar numeric)

		% safeguard
	if nargin < 1 || ~ismatrix( data ) || ~isnumeric( data )
		error( 'invalid argument: data' );
	end

	if nargin < 2 || ~isrow( epsilons ) || ~isnumeric( epsilons ) || numel( epsilons ) ~= size( data, 2 )
		error( 'invalid argument: epsilons' );
	end

	if nargin < 3 || ~isrow( betas ) || ~isnumeric( betas ) || numel( betas ) ~= size( data, 1 )
		error( 'invalid argument: betas' );
	end

	if nargin < 4 || ~isscalar( cval ) || ~isnumeric( cval )
		error( 'invalid argument: cval' );
	end

	style = xis.hStyle.instance();

		% backup previous colorbars
	hcs = findall( gcf(), 'Tag', 'Colorbar' );

	prevlims = zeros( numel( hcs ), 2 );
	prevticks = {};

	for i = 1:numel( hcs )
		prevlims(i, :) = get( hcs(i), 'YLim' );
		prevticks{i} = get( hcs(i), 'YTick' );
	end

		% extend colormap
	nprevcols = size( colormap(), 1 );
	ncols = 127;

	colormap( cat( 1, colormap(), style.gradient3( ncols, ...
		style.color( 'cold', 0 ), style.color( 'neutral', +2 ), style.color( 'warm', 0 ) ) ) );

		% rescale data to colors
	datamin = min( data(:) );
	datamax = max( data(:) );

	if cval < datamin || cval > datamax
		error( 'invalid argument: cval' );
	end

	datahw = max( cval-datamin, datamax-cval );

	function val = rescale( val )
		if isnan( val )
			val = 1;
		else
			dst = (val-cval) / datahw;

			if mod( ncols, 2 ) == 0 % even number of colors
				cdst = round( dst * (ncols/2 - 1) );
				val = nprevcols + ncols/2 + cdst;
				if dst >= 0
					val = val + 1;
				end
			else % odd number
				cdst = round( dst * floor( ncols/2 ) );
				val = nprevcols + ceil( ncols/2 ) + cdst;
			end
		end
	end

	data = arrayfun( @rescale, data );

		% prepare colorbar
	plot( linspace( cval-datahw, cval+datahw, ncols ) ); % let matlab choose optimal ticks and labels, TODO: exponential scale factor!

	ticks = get( gca(), 'YTick' );
	ticklabels = get( gca(), 'YTickLabel' );

		% plot data
	xlabel( 'epsilon' );
	ylabel( 'beta' );

	xlim( [min( epsilons ), max( epsilons )] );
	ylim( [min( betas ), max( betas )] );

	image( epsilons, betas, data );
		
		% insert colorbar
	hc = colorbar();

	ylim( hc, [nprevcols+1, nprevcols+ncols] );

	set( hc, 'YTick', nprevcols + 1 + (ticks-cval+datahw) / (2*datahw) * (ncols-1) );
	set( hc, 'YTickLabel', ticklabels );

		% restore previous colorbars
	for i = 1:numel( hcs )
		set( hcs(i), 'YLim', prevlims(i, :) );
		set( hcs(i), 'YTick', prevticks{i} );
	end

end

