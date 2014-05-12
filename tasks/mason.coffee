mason = require '../source'

module.exports = (grunt) ->
	grunt.registerMultiTask 'mason', 'Compiles Mason source files', ->
		# Merge task-specific and/or target-specific options with these defaults.
		options = @options
			prelude: null

		prelude =
			if options.prelude?
				grunt.file.read options.prelude

		# Iterate over all specified file groups.
		@files.forEach (fileGroup) ->
			fileGroup.src.forEach (src) ->
				dest = fileGroup.dest

				grunt.verbose.writeln "Compiling #{src} -> #{dest}"
				text = grunt.file.read src
				{ code, map } = mason.compile text,
					fileName: src
					outFileName: dest
					prelude: prelude
				grunt.file.write dest, code
				grunt.file.write "#{dest}.map", map
