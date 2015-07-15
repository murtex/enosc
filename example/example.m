function example( infile, plotdir )
% test example
%
% EXAMPLE( infile, plotdir )
%
% INPUT
% infile : data filename (row char)
% plotdir : plot directory (row char)

		% safeguard
	if nargin < 1 || ~isrow( infile ) || ~ischar( infile ) || exist( infile, 'file' ) ~= 2
		error( 'invalid argument: infile' );
	end

	if nargin < 2 || ~isrow( plotdir ) || ~ischar( plotdir )
		error( 'invalid argument: plotdir' );
	end

		% initialize framework
	addpath( '../xis/' );
	addpath( '../enosc/' );

	logger = xis.hLogger.instance( 'example.m.log' );
	logger.tab( 'plot examples...' );

		% plot some data
	enosc.plot_raw();

		% done
	logger.untab();
	logger.log( 'done.' );

end

