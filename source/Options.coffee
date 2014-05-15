{ basename } = require 'path'
{ check, type, typeExist } = require './help/check'

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
		@_checks =
			if options.check == yes or not options.checks?
				in: yes
				out: yes
				type: yes
			else if options.checks == no
				in: no
				out: no
				type: no
			else
				in: Boolean options.in
				out: Boolean options.out
				type: Boolean options.type

		@_fileName = options.fileName
		@_outFileName = options.outFileName
		@_prelude = options.prelude

		type @_fileName, String, @_outFileName, String
		typeExist @_prelude, String

	checks: (checkKind) ->
		check checkKind in [ 'in', 'out', 'type' ]
		@_checks[checkKind]

	###
	Full path to the file we are compiling.
	###
	fileName: -> @_fileName

	###
	Full path to the destination file.
	###
	outFileName: -> @_outFileName

	###
	Text to be appended before every file.
	###
	prelude: -> @_prelude

	###
	Basename of the destination file.
	###
	shortOutFileName: ->
		basename @outFileName()
