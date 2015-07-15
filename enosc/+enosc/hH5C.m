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

		size = 0; % number of oscillators (scalar numeric)
		mean = false; % ensemble mean flag (scalar logical)
		meanfield = false; % meanfield flag (scalar logical)

	end

		% methods
	methods (Access = public)

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
				this.size = info.Dataspace.Size(1);
				this.dim = info.Dataspace.Size(4); % dimensionality
			else
				if this.polar_track
					info = h5info( filename, '/polar/x' );
					this.size = info.Dataspace.Size(1);
				end
			end

			if this.raw_track % ensemble mean
				info = h5info( filename, '/raw/mx' );
				this.mean = true;
			else
				if this.polar_track
					info = h5info( filename, '/polar/mx' );
					this.mean = true;
				else
					if this.funnel_track
						info = h5info( filename, '/funnel/mx' );
						this.mean = true;
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

