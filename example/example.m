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

	if exist( plotdir, 'dir' ) ~= 7 % prepare output directory
		mkdir( plotdir );
	end

		% initialize framework
	addpath( '../xis/' );
	addpath( '../enosc/' );

	logger = xis.hLogger.instance( 'example.m.log' );
	logger.tab( 'plot examples...' );

		% read data
	h5c = enosc.hH5C( datafile );

		% plot some figures
	enosc.fig_funnel( h5c, [], [], [], fullfile( plotdir, 'funnel.png' ) );

	mask_funnel = h5c.mask_funnel( [], [], [], [-Inf, Inf] );
	enosc.fig_order( h5c, [], [], [], fullfile( plotdir, 'order.png' ), mask_funnel );

	mask_order = h5c.mask_order( [], [], [], [-Inf, Inf] );
	enosc.fig_detune( h5c, [], [], [], fullfile( plotdir, 'detune.png' ), mask_funnel & mask_order );

	enosc.fig_raw( h5c, [], 0.004, 0.0, fullfile( plotdir, 'raw0.png' ) );
	enosc.fig_raw( h5c, [], 0.015, 0.4, fullfile( plotdir, 'raw1.png' ) );

		% done
	logger.untab();
	logger.log( 'done.' );

end

