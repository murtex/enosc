function h5c = example( datafile, plotdir )
% test example
%
% EXAMPLE( datafile, plotdir )
%
% INPUT
% datafile : data filename (row char)
% plotdir : plot directory (row char)

		% safeguard
	if nargin < 1 || ~isrow( datafile ) || ~ischar( datafile ) || exist( datafile, 'file' ) ~= 2
		error( 'invalid argument: datafile' );
	end

	if nargin < 2 || ~isrow( plotdir ) || ~ischar( plotdir )
		error( 'invalid argument: plotdir' );
	end

		% initialize framework
	addpath( '../xis/' );
	addpath( '../enosc/' );

	logger = xis.hLogger.instance( 'example.m.log' );
	logger.tab( 'plot examples...' );

		% prepare plot directory
	if exist( plotdir, 'dir' ) ~= 7
		mkdir( plotdir );
	end

		% create data container
	h5c = enosc.hH5C( datafile );

		% DEBUG: some plots
	enosc.plot_raw( h5c, [], 0, 0, fullfile( plotdir, 'raw.png' ) );

		% done
	logger.untab();
	logger.log( 'done.' );

end

