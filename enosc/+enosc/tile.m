function ppos = tile( ncols, nrows, tilex, tiley, tilesep )
% tiling figure
%
% ppos = tile( ncols, nrows, tilex=59, tiley=89, tilesep=11 )
%
% INPUTS
% ncols : number of columns (scalar numeric)
% nrows : number of rows (scalar numeric)
% tilex : tile width (scalar numeric)
% tiley : tile height (scalar numeric)
% tilesep : tile separation (scalar numeric)
%
% OUTPUTS
% ppos : 'PaperPosition' property

		% safeguard
	if nargin < 1 || ~isscalar( ncols ) || ~isnumeric( ncols )
		error( 'invalid argument: ncols' );
	end

	if nargin < 2 || ~isscalar( nrows ) || ~isnumeric( nrows )
		error( 'invalid argument: nrows' );
	end

	if nargin < 3
		tilex = 59;
	end
	if ~isscalar( tilex ) || ~isnumeric( tilex )
		error( 'invalid argument: tilex' );
	end

	if nargin < 4
		tiley = 89;
	end
	if ~isscalar( tiley ) || ~isnumeric( tiley )
		error( 'invalid argument: tiley' );
	end

	if nargin < 5
		tilesep = 11;
	end
	if ~isscalar( tilesep ) || ~isnumeric( tilesep )
		error( 'invalid argument: tilesep' );
	end

		% set tile size
	ppos(1) = 0;
	ppos(2) = 0;
	ppos(3) = ncols * tilex + (ncols-1) * tilesep;
	ppos(4) = nrows * tiley + (nrows-1) * tilesep;

end

