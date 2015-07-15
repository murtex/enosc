function [seq, iseq] = parsnap( seq, range )
% snap parameters to sequence
%
% [seq, iseq] = PARSNAP( seq, range )
%
% INPUT
% seq : parameter sequence (row numeric)
% range : parameter range (row numeric)
%
% OUTPUT
% seq : snapped parameter sequence (row numeric)
% iseq : snap indices (row numeric)


		% safeguard
	if nargin < 1 || ~isrow( seq ) || ~isnumeric( seq )
		error( 'invalid argument: seq' );
	end

	if nargin < 2 || ~isrow( range ) || ~isnumeric( range ) || numel( range ) > 2
		error( 'invalid argument: range' );
	end
	if numel( range ) < 2
		range(2) = range(1);
	end

		% snap range
	[~, iseq] = arrayfun( @( x ) min( abs( seq-x ) ), range, 'UniformOutput', true ); % snapping

	iseq = iseq(1):iseq(end); % sequencing

	seq = seq(iseq); % snapped parameters
	
end

