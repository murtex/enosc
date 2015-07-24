classdef hH5C < handle
% hdf5 data container

		% properties
	properties (Access = public)

			% general
		filename = ''; % data filename (row char)
		fileinfo = struct(); % data file information (scalar struct)

			% static data
		times = []; % stepping times (row numeric)
		dt = NaN; % stepping delta (scalar numeric)

		epsilons = []; % epsilon coupling parameters (row numeric)
		betas = []; % beta coupling parameters (row numeric)

			% tracks
		raw_track = false; % raw track flag (scalar logical)
		polar_track = false; % polar track flag (scalar logical)
		funnel_track = false; % funnel track flag (scalar logical)

			% observables
		dim = 0; % dimensionality (scalar numeric)

		oscillator = false; % oscillator flag (scalar logical)
		ensemble = false; % ensemble mean flag (scalar logical)
		meanfield = false; % meanfield flag (scalar logical)

	end

		% methods
	methods (Access = public)

		function mask = mask_funnel( this, times, epsilons, betas, range )
		% compute funnel mask
		%
		% mask = MASK_FUNNEL( this, times, epsilons, betas, range )
		%
		% INPUT
		% this : data container (scalar object)
		% times : stepping time range (row numeric)
		% epsilons : epsilon coupling range (row numeric)
		% betas : beta coupling range (row numeric)
		% range : funnel range (row numeric)
		%
		% OUTPUT
		% mask : funnel mask (matrix logical)

				% safeguard
			if nargin < 1 || ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || (~isempty( times ) && ~isrow( times )) || ~isnumeric( times )
				error( 'invalid argument: times' );
			end
			if isempty( times )
				times = [this.times(1), this.times(end)];
			end

			if nargin < 3 || (~isempty( epsilons ) && ~isrow( epsilons )) || ~isnumeric( epsilons )
				error( 'invalid argument: epsilons' );
			end
			if isempty( epsilons )
				epsilons = [this.epsilons(1), this.epsilons(end)];
			end

			if nargin < 3 || (~isempty( betas ) && ~isrow( betas )) || ~isnumeric( betas )
				error( 'invalid argument: betas' );
			end
			if isempty( betas )
				betas = [this.betas(1), this.betas(end)];
			end

			if nargin < 5 || ~isrow( range ) || numel( range ) ~= 2 || ~isnumeric( range )
				error( 'invalid argument: range' );
			end

				% snap parameters
			[times, itimes] = enosc.parsnap( this.times, times );
			[epsilons, iepsilons] = enosc.parsnap( this.epsilons, epsilons );
			[betas, ibetas] = enosc.parsnap( this.betas, betas );

				% read funnel data
			starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
			counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), this.ensemble];
			mx = double( abs( sum( h5read( this.filename, '/funnel/mx', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

			starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
			counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), this.meanfield];
			mf = double( abs( sum( h5read( this.filename, '/funnel/mf', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

				% normalize funnel data
			mxmax = max( mx(:) );
			if mxmax ~= 0
				mx = mx / mxmax;
			end
			mfmax = max( mf(:) );
			if mfmax ~= 0
				mf = mf / mfmax;
			end

				% compute total funnel
			total = squeeze( (mx + mf) / 2 );

				% generate mask
			mask = true( size( total ) );
			mask(total < range(1) | total > range(2)) = false;

		end

		function mask = mask_order( this, times, epsilons, betas, range )
		% compute order mask
		%
		% mask = MASK_ORDER( this, times, epsilons, betas, range )
		%
		% INPUT
		% this : data container (scalar object)
		% times : stepping time range (row numeric)
		% epsilons : epsilon coupling range (row numeric)
		% betas : beta coupling range (row numeric)
		% range : order range (row numeric)
		%
		% OUTPUT
		% mask : order mask (matrix logical)

				% safeguard
			if nargin < 1 || ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || (~isempty( times ) && ~isrow( times )) || ~isnumeric( times )
				error( 'invalid argument: times' );
			end
			if isempty( times )
				times = [this.times(1), this.times(end)];
			end

			if nargin < 3 || (~isempty( epsilons ) && ~isrow( epsilons )) || ~isnumeric( epsilons )
				error( 'invalid argument: epsilons' );
			end
			if isempty( epsilons )
				epsilons = [this.epsilons(1), this.epsilons(end)];
			end

			if nargin < 3 || (~isempty( betas ) && ~isrow( betas )) || ~isnumeric( betas )
				error( 'invalid argument: betas' );
			end
			if isempty( betas )
				betas = [this.betas(1), this.betas(end)];
			end

			if nargin < 5 || ~isrow( range ) || numel( range ) ~= 2 || ~isnumeric( range )
				error( 'invalid argument: range' );
			end

				% snap parameters
			[times, itimes] = enosc.parsnap( this.times, times );
			[epsilons, iepsilons] = enosc.parsnap( this.epsilons, epsilons );
			[betas, ibetas] = enosc.parsnap( this.betas, betas );

				% read amplitude data
			starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
			counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), this.ensemble];
			mx = double( abs( mean( h5read( this.filename, '/polar/mx', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

			starts = [itimes(1), 1, iepsilons(1), ibetas(1), 1];
			counts = [numel( itimes ), 1, numel( iepsilons ), numel( ibetas ), this.meanfield];
			mf = double( abs( mean( h5read( this.filename, '/polar/mf', fliplr( starts ), fliplr( counts ) ), 5 ) ) );

				% compute order
			order = squeeze( mf ./ mx );

				% generate mask
			mask = true( size( order ) );
			mask(order < range(1) | order > range(2)) = false;

		end

		function this = hH5C( filename )
		% class constructor
		%
		% this = hH5C( filename )
		%
		% INPUT
		% filename : data filename (row char)
		%
		% OUTPUT
		% this : data container

				% safeguard
			if nargin < 1 || ~isrow( filename ) || ~ischar( filename )
				error( 'invalid argument: filename' );
			end

				% set general
			this.filename = filename;
			this.fileinfo = h5info( filename );

				% read static data
			this.times = double( transpose( h5read( filename, '/times' ) ) ); % stepping
			this.dt = double( h5read( filename, '/dt' ) );

			this.epsilons = double( transpose( h5read( filename, '/epsilons' ) ) ); % coupling
			this.betas = double( transpose( h5read( filename, '/betas' ) ) );

				% get track flags
			info = h5info( filename, '/raw/x' ); % raw
			if info.Dataspace.Size(1) > 0
				this.raw_track = true;
			else
				info = h5info( filename, '/raw/mx' );
				if info.Dataspace.Size(1) > 0
					this.raw_track = true;
				end
			end

			info = h5info( filename, '/polar/x' ); % polar
			if info.Dataspace.Size(1) > 0
				this.polar_track = true;
			else
				info = h5info( filename, '/polar/mx' );
				if info.Dataspace.Size(1) > 0
					this.polar_track = true;
				else
					info = h5info( filename, '/polar/mf' );
					if info.Dataspace.Size(1) > 0
						this.polar_track = true;
					end
				end
			end

			info = h5info( filename, '/funnel/mx' ); % funnel
			if info.Dataspace.Size(1) > 0
				this.funnel_track = true;
			else
				info = h5info( filename, '/funnel/mf' );
				if info.Dataspace.Size(1) > 0
					this.funnel_track = true;
				end
			end

				% get observables
			if this.raw_track % oscillators
				info = h5info( filename, '/raw/x' );
				this.oscillator = true;
				this.dim = info.Dataspace.Size(4); % dimensionality
			else
				if this.polar_track
					info = h5info( filename, '/polar/x' );
					this.oscillator = true;
				end
			end

			if this.raw_track % ensemble mean
				info = h5info( filename, '/raw/mx' );
				this.ensemble = true;
			else
				if this.polar_track
					info = h5info( filename, '/polar/mx' );
					this.ensemble = true;
				else
					if this.funnel_track
						info = h5info( filename, '/funnel/mx' );
						this.ensemble = true;
					end
				end
			end

			if this.polar_track % meanfield
				info = h5info( filename, '/polar/mf' );
				this.meanfield = true;
			else
				if this.funnel_track
					info = h5info( filename, '/funnel/mf' );
					this.meanfield = true;
				end
			end

		end

	end % methods

end % classdef

