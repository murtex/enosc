function plot_map2( label, data, epsilons, betas )
% plot two-color gradient map
%
% PLOT_MAP2( label, data, epsilons, betas )
%
% INPUT
% label : map label (row char)
% data : map data (matrix numeric)
% epsilons : epsilon coupling values (row numeric)
% betas : beta coupling values (row numeric)

		% safeguard
	if nargin < 1 || ~isrow( label ) || ~ischar( label )
		error( 'invalid argument: label' );
	end

	if nargin < 2 || ~ismatrix( data ) || ~isnumeric( data )
		error( 'invalid argument: data' );
	end

	if nargin < 3 || ~isrow( epsilons ) || ~isnumeric( epsilons ) || numel( epsilons ) ~= size( data, 2 )
		error( 'invalid argument: epsilons' );
	end

	if nargin < 4 || ~isrow( betas ) || ~isnumeric( betas ) || numel( betas ) ~= size( data, 1 )
		error( 'invalid argument: betas' );
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

	colormap( cat( 1, colormap(), style.gradient2( ncols, ...
		style.color( 'neutral', +2 ), style.color( 'cold', 0 ) ) ) );

		% rescale data to colors
	datamin = min( data(:) );
	datamax = max( data(:) );

	function val = rescale( val )
		if isnan( val )
			val = 1;
		else
			col = round( (val-datamin) / (datamax-datamin) * (ncols-1) );
			val = nprevcols + col+1;
		end
	end

	data = arrayfun( @rescale, data );

		% prepare colorbar
	plot( linspace( datamin, datamax, ncols ) ); % let matlab choose optimal ticks and labels

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

	ylabel( hc, label );
	ylim( hc, [nprevcols+0.5, nprevcols+0.5+ncols] );

	set( hc, 'YTick', nprevcols + 1 + (ticks-datamin) / (datamax-datamin) * (ncols-1) );
	set( hc, 'YTickLabel', ticklabels );

		% restore previous colorbars
	for i = 1:numel( hcs )
		set( hcs(i), 'YLim', prevlims(i, :) );
		set( hcs(i), 'YTick', prevticks{i} );
	end

end

