function s = par2str( seq )
% parameters (sequence) to string
%
% s = PAR2STR( seq )
%
% INPUT
% seq : parameter sequence (row numeric)
%
% OUTPUT
% s : parameter string (row char)


		% safeguard
	if nargin < 1 || ~isrow( seq ) || ~isnumeric( seq )
		error( 'invalid argument: seq' );
	end

		% string conversion
	if seq(1) == seq(end)
		s = num2str( seq(1) );
	else
		s = cat( 2, num2str( seq(1) ), '..', num2str( seq(end) ) );
	end
	
end

