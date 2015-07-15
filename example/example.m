function plot( infile, outdir )
% test example
%
% TEST( infile, outdir )
%
% INPUT
% infile : data filename (row char)
% outdir : output directory (row char)

	'bla'

		% safeguard
	if nargin < 1 || ~isrow( infile ) || ~ischar( infile )
		error( 'invalid argument: infile' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir )
		error( 'invalid argument: outdir' );
	end

end

