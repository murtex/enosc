classdef (Sealed = true) hLogger < handle
% hierarchic logging (singleton)

		% properties
	properties (Access = public)

		hierarchy = 0; % hierarchy (scalar numeric)
		hierarchymax = Inf; % maximum hierarchy (scalar numeric)

		tics = tic(); % timing (matlab internal)

	end

		% public methods
	methods (Access = public)

		function tab( this, msg, varargin )
		% raise hierarchy
		%
		% TAB( this )
		% TAB( this, msg, ... )
		%
		% INPUT
		% this : logger (scalar object)
		% msg : message, fprintf-format (row char)
		% ... : format arguments

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin > 1 && (~isrow( msg ) || ~ischar( msg ))
				error( 'invalid argument: msg' );
			end

				% log message and raise hierarchy
			if nargin > 1
				this.log( msg, varargin{:} );
			end

			this.hierarchy = this.hierarchy + 1;

				% start hierarchy timing
			this.tics(this.hierarchy + 1) = tic();

		end

		function untab( this, msg, varargin )
		% lower hierarchy
		%
		% UNTAB( this )
		% UNTAB( this, msg, ... )
		%
		% INPUT
		% this : logger (scalar object)
		% msg : message, fprintf-format (row char)
		% ... : format arguments

				% safeguard
			if ~isscalar( this ) || this.hierarchy < 1
				error( 'invalid argument: this' );
			end

			if nargin > 1 && (~isrow( msg ) || ~ischar( msg ))
				error( 'invalid argument: msg' );
			end

				% log message, timing and lower hierarchy
			if nargin > 1
				this.log( msg, varargin{:} );
			end

			timing = toc( this.tics(this.hierarchy + 1) ); % log timing >10s
			if timing > 10
				this.log( '(%.3f)', timing );
			end

			this.hierarchy = this.hierarchy - 1;

		end

		function log( this, msg, varargin )
		% message logging
		%
		% LOG( this, msg, ... )
		%
		% INPUT
		% this : logger (scalar object)
		% msg : message, fprintf-format (row char)
		% ... : format arguments

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

			if nargin < 2 || ~isrow( msg ) || ~ischar( msg )
				error( 'invalid argument: msg' );
			end

			if this.hierarchy > this.hierarchymax
				return;
			end

				% extract caller module
			%mod = '';

			%st = dbstack( 1, '-completenames' );
			%nst = size( st, 1 );

			%for i = 1:nst
				%[path, name, ext] = fileparts( st(i).file );

				%r = path;
				%while true
					%[mod, r] = strtok( r, filesep() );
					%if isempty( r )
						%break;
					%end
				%end

				%if ~strcmp( mod, '+xis' )
					%break;
				%end
			%end

				% log header and message
			tic = sprintf( '[%10.3f]', toc( this.tics(1) ) );
			ind = repmat( '..', 1, this.hierarchy );
			%mod = sprintf( '[%s]', mod );
			msg = sprintf( msg, varargin{:} );

			%fprintf( '%s %s%s %s\n', tic, ind, mod, msg );
			fprintf( '%s %s%s\n', tic, ind, msg );

		end

		function progress( this, varargin )
		% progression logging
		%
		% PROGRESS( this )
		% PROGRESS( this, msg, ... )
		% PROGRESS( this, step, n )
		%
		% INPUT
		% this : logger (scalar object)
		% msg : initial message, fprintf-format (row char)
		% step: current progressing step (scalar numeric)
		% n : maximum progressing steps (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% start progression
			persistent decile_last;

			if nargin == 1 || ischar( varargin{1} )

					% safeguard
				if nargin > 1 && ~isrow( varargin{1} )
					error( 'invalid argument: msg' );
				end

					% start logging
				if nargin > 1
					this.tab( varargin{:} );
				else
					this.tab();
				end

				if this.hierarchy <= this.hierarchymax
					tic = sprintf( '[%10.3f]', toc( this.tics(1) ) );
					ind = repmat( '..', 1, this.hierarchy );
					msg = '0%..';

					fprintf( '%s %s%s', tic, ind, msg );
				end

				decile_last = 0;

				% continue/stop progression
			elseif isnumeric( varargin{1} ) && numel( varargin ) > 1

					% safeguard
				step = varargin{1};
				if ~isscalar( step )
					error( 'invalid argument: step' );
				end

				n = varargin{2};
				if ~isscalar( n ) || ~isnumeric( n )
					error( 'invalid argument: n' );
				end

					% continue logging
				decile_cur = floor( 10 * step / n );

				if this.hierarchy <= this.hierarchymax
					for i = decile_last+1:decile_cur
						fprintf( '%d%%', 10 * i );
						if i ~= 10
							fprintf( '..' );
						end
					end
				end

				decile_last = decile_cur;

					% stop logging
				if step == n
					if this.hierarchy <= this.hierarchymax
						fprintf( '\n' );
					end
					this.untab();
				end

				% safeguard
			else
				error( 'invalid arguments' );
			end

		end

		function p = peakmem( this )
		% get peak memory
		%
		% mem = PEAKMEM( this )
		%
		% INPUT
		% this : logger (scalar object)
		%
		% OUTPUT
		% p : peak memory usage in bytes (scalar numeric)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% get peak memory
			p = NaN;

			if isunix() % unix/linux

					% use proc interface
				[~, ret] = unix( sprintf( 'cat /proc/%d/status', feature( 'getpid' ) ) ); % TODO: using undocumented function 'feature'!

					% extract peak info
				retlines = regexp( ret, '\n', 'split' );

				n = numel( retlines );
				for i = 1:n
					if strncmp( retlines{i}, 'VmPeak:', 7 )
						valstring = regexp( retlines{i}, ' ', 'split' );
						p = str2double( valstring{2} ) * 1024;
						break;
					end
				end

			end

		end

		function delete( this )
		% class destructor
		%
		% DELETE( this )
		%
		% INPUT
		% this : logger (scalar object)

				% safeguard
			if ~isscalar( this )
				error( 'invalid argument: this' );
			end

				% stop logging
			diary( 'off' );

		end

	end % public methods

		% static methods
	methods (Static = true)

		function that = instance( logfile )
		% class singleton
		%
		% that = INSTANCE()
		% that = INSTANCE( logfile )
		%
		% INPUT
		% logfile : logging filename (row char)
		%
		% OUTPUT
		% that : logger (scalar object)

				% ensure singleton existence
			persistent this;

			if isempty( this ) || ~isvalid( this )
				this = xis.hLogger();
			end

				% reset logger
			if nargin > 0

					% safeguard
				if ~isrow( logfile ) || ~ischar( logfile )
					error( 'invalid argument: logfile' );
				end

					% reset
				delete( this ); % stop logging

				this = xis.hLogger.instance(); % (re-)start logging

				if exist( logfile, 'file' ) == 2
					delete( logfile );
				end

				diary( logfile );
				this.tics = tic();

			end

				% return singleton
			that = this;

		end

	end % static methods

		% private methods
	methods (Access = private)

		function this = hLogger()
		% class constructor
		%
		% this = HLOGGER()
		%
		% OUTPUT
		% this : logger (scalar object)

			% nop

		end

	end % private methods

end % classdef

