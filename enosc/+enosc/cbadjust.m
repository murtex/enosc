function cbadjust( ha, hc )
% adjust colorbar
%
% CBADJUST( ha, hc )
%
% INPUT
% ha : axes handle (scalar object)
% hc : colorbar handle (scalar object)

		% safeguard
	if nargin < 1 || ~isscalar( ha ) || ~ishandle( ha )
		error( 'invalid argument: ha' );
	end

	if nargin < 2 || ~isscalar( hc ) || ~ishandle( hc )
		error( 'invalid argument: hc' );
	end

		% adjust position
	axpos = get( ha, 'Position' );
	cbpos = get( hc, 'Position' );

	cbpos(1) = cbpos(1) - cbpos(3) / 3; % narrow position
	cbpos(2) = axpos(2);
	cbpos(3) = cbpos(3) / 2; % narrow width
	cbpos(4) = axpos(4);

	set( hc, 'Position', cbpos );
	set( ha, 'Position', axpos );

end

