nopt = require 'nopt'
{ type } = require './help/check'

###
Stores compilation options.
Run `smith --help` to see all.
###
module.exports = class Options
	###
	Constructs options from an object.
	All members are  optional.
	@param options
	  Object containing options specified in `smith --help`.
	@example
	  Options
	  	nazi: yes
	###
	constructor: (options) ->
		options ?= { }
		@_checks = options.checks ? yes
		@_fileName = options.fileName
		@_outFileName = options.outFileName

	withFileName: (fileName) ->
		new Options
			checks: @checks()
			fileName: fileName

	checks: -> @_checks
	fileName: -> @_fileName
	outFileName: -> @_outFileName

	shortOutFileName: ->
		path = require 'path'
		path.basename @outFileName()

	###
	Gets Options from this processe's command line.
	###
	@fromCommandLine: ->
		options = nopt
			checks: Boolean
			'in': String
			out: String
			help: Boolean
			meta: Boolean
			just: String
			'print-module-defines': Boolean
			verbose: Boolean
			watch: Boolean
			nazi: Boolean

		if options.help
			info = require './info'
			console.log """
			Smith compiler version #{info.version}.
			Use --no-X to turn of option X.
			Options:
			--in: Input directory (default 'source').
			--out: Ouput directory (default 'js').
			--checks: Turns on in, out, and type checks.
				(Does not affect ✔ not in a in or out block).
			--copy-sources: If so, copies .smith files to out directory.
			--help: Print this.
			--just: Only compile one file.
			--meta: Include meta with functions (default yes).
			--nazi: Suppress unconventional syntax (default yes).
			--print-module-defines: Output code prints when modules are defined.
			--verbose: Print when compiling files.
			--watch: Wait and compile again whenever files are changed.
			"""

		new Options options
