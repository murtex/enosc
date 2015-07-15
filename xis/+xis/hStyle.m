classdef (Sealed = true) hStyle < handle
% uniform styling (singleton)
%
% SEE
% old-phoenix-styled colors
% http://paletton.com/#uid=33F0E0ktwsofoExmjuXvCloGWen

		% properties
	properties (GetAccess = public, SetAccess = private)
	end

		% public methods
	methods (Access = public)

		function fig = figure( this, varargin )
		% create figure
		%
		% fig = FIGURE( this, ... )
		%
		% INPUT
		% this : style (scalar object)
		% ... : additional properties
		%
		% OUTPUT
		% fig : figure (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% create figure
			ws = warning(); % disable warnings
			warning( 'off', 'all' );

			fig = figure( ...
				'Visible', 'off', ...
				'InvertHardCopy', 'off', ...
				'Color', this.color( 'grey', this.scale( -1/3 ) ), ...
				'defaultAxesFontSize', 8, ...
				'defaultAxesNextPlot', 'add', ...
				'defaultAxesBox', 'on', 'defaultAxesLayer', 'top', ...
				'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
				varargin{:} );
				%'defaultAxesTitleFontSizeMultiplier', 1, 'defaultAxesLabelFontSizeMultiplier', 1, ...
				%'defaultAxesGridColor', this.color( 'neutral', -2 ), ...

			warning( ws ); % (re-)enable warnings
	
		end

		function print( this, plotfile )
		% print figure
		%
		% print( this, plotfile )
		%
		% INPUT
		% this : style (scalar object)
		% plotfile : plot filename (row char)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( plotfile ) || ~ischar( plotfile )
				error( 'invalid argument: plotfile' );
			end

				% print figure
			print( plotfile, '-dpng', '-r128' );

			%imwrite( hardcopy( gcf(), '-dzbuffer', '-r120' ), sprintf( '%s.png', plotfile ), 'png' );

		end

		function rgb = color( this, name, shade )
		% get color
		%
		% rgb = COLOR( this, id, shade )
		%
		% INPUT
		% this : style (scalar object)
		% name : color name (row char)
		% shade : color shade (scalar numeric)
		%
		% OUTPUT
		% rgb : rgb-values (row numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( name ) || ~ischar( name )
				error( 'invalid argument: name' );
			end

			if nargin < 3 || ~isscalar( shade ) || ~isnumeric( shade )
				error( 'invalid argument: shade' );
			end

				% clamp color shade
			switch name
				case 'grey'
					shade(shade < 0) = 0;
					shade(shade > 1) = 1;
				otherwise
					shade(shade < -2) = -2;
					shade(shade > +2) = +2;
			end

				% base colors
			white = [1, 1, 1];

			function rgb = cold( shade )
				switch shade
					case -2
						rgb = hex2dec( {'04', '21', '4c'} )/255;
					case -1
						rgb = hex2dec( {'0b', '34', '70'} )/255;
					case 0
						rgb = hex2dec( {'18', '4a', '95'} )/255;
					case +1
						rgb = hex2dec( {'3b', '65', 'a3'} )/255;
					case +2
						rgb = hex2dec( {'6d', '8f', 'c2'} )/255;
				end
				rgb = transpose( rgb );
			end

			function rgb = warm( shade )
				switch shade
					case -2
						rgb = hex2dec( {'72', '1d', '00'} )/255;
					case -1
						rgb = hex2dec( {'aa', '2d', '02'} )/255;
					case 0
						rgb = hex2dec( {'e2', '47', '12'} )/255;
					case +1
						rgb = hex2dec( {'f7', '77', '4b'} )/255;
					case +2
						rgb = hex2dec( {'ff', 'a4', '84'} )/255;
				end
				rgb = transpose( rgb );
			end

			function rgb = neutral( shade )
				switch shade
					case -2
						rgb = 0.10 * white;
					case -1
						rgb = 0.13 * white;
					case 0
						rgb = 0.25 * white;
					case +1
						rgb = 0.50 * white;
					case +2
						rgb = 0.70 * white;
				end
			end


				% set shaded color
			rgb1 = neutral( 0 );
			rgb2 = neutral( 0 );

			switch name
				case 'cold'
					rgb1 = cold( floor( shade ) );
					rgb2 = cold( ceil( shade ) );
				case 'warm'
					rgb1 = warm( floor( shade ) );
					rgb2 = warm( ceil( shade ) );
				case 'neutral'
					rgb1 = neutral( floor( shade ) );
					rgb2 = neutral( ceil( shade ) );
				case 'grey'
					rgb1 = shade * white;
					rgb2 = rgb1;
				otherwise
					error( 'invalid argument: name' );
			end

			rgb = (rgb1 + rgb2) / 2;

		end

		function cols = gradient( this, n, col1, col2 )
		% get two-color gradient
		%
		% cols = GRADIENT( this, n, col1, col2 )
		%
		% INPUT
		% this : style (scalar object)
		% n : number of shades (scalar numeric)
		% col1 : first color (row numeric)
		% col2 : seconds color (row numeric)
		%
		% OUTPUT
		% cols : gradient colors (matrix numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isscalar( n ) || ~isnumeric( n )
				error( 'invalid argument: n' );
			end

			if nargin < 3 || ~isrow( col1 ) || ~isnumeric( col1 )
				error( 'invalid argument: col1' );
			end

			if nargin < 4 || ~isrow( col2 ) || ~isnumeric( col2 ) || numel( col2 ) ~= numel( col1 )
				error( 'invalid argument: col2' );
			end

				% set gradient colors
			m = numel( col1 );

			cols = zeros( n, m ); % pre-allocation

			for i = 1:m
				cols(:, i) = linspace( col1(i), col2(i), n );
			end

		end

		function s = scale( this, rank )
		% get scale factor
		%
		% s = SCALE( this, rank )
		%
		% INPUT
		% this : style (scalar object)
		% rank : scale rank (scalar numeric)
		%
		% OUTPUT
		% scale : scale factor (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isscalar( rank ) || ~isnumeric( rank )
				error( 'invalid argument: rank' );
			end

				% set rankd scale
			s = 2^(rank * 1/2);

		end

		function k = bins( this, data )
		% optimal number of histogram bins
		%
		% k = bins( this, data )
		%
		% INPUT
		% this : style (scalar object)
		% data : data (vector numeric)
		%
		% OUTPUT
		% k : number of bins (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isvector( data ) || ~isnumeric( data )
				error( 'invalid argument: data' );
			end

				% try several rules (some would return less than a single bin)
			n = numel( data );

			ks = []; % pre-allocation

			g1 = skewness( data ); % doane's formula
			sigmag1 = sqrt( 6*(n-2) / ((n+1)*(n+3)) );
			ks(end+1) = 1 + log2( n ) + log2( 1 + abs( g1 )/sigmag1 );

			ks(end+1) = 3.5 * std( data ) / (n^(1/3)); % scott's normal reference rule

			ks(end+1) = 2 * iqr( data ) / (n^(1/3)); % freedman-diaconis rule

				% choose maximum number of bins
			k = max( ks );

		end

	end % public methods

		% static methods
	methods (Static = true)

		function that = instance()
		% class singleton
		%
		% that = INSTANCE()
		%
		% OUTPUT
		% that : style (scalar object)

				% ensure singleton validity
			persistent this;

			if isempty( this )
				this = xis.hStyle(); % create instance
			end

				% return singleton
			that = this;

		end

	end % static methods

		% private methods
	methods (Access = private)

		function this = hStyle()
		% class constructor
		%
		% this = HSTYLE()
		%
		% OUTPUT
		% this : style (scalar object)

			% nop

		end

	end % private methods

end % classdef

