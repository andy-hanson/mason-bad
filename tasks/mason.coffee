mason = require '../source'

module.exports = (grunt) ->
	grunt.registerMultiTask 'mason', 'Compiles Mason source files', ->
		# Merge task-specific and/or target-specific options with these defaults.
		options = @options
			punctuation: '.'
			separator: ', '

		# Iterate over all specified file groups.
		@files.forEach (fileGroup) ->
			fileGroup.src.forEach (src) ->
				dest = fileGroup.dest

				grunt.verbose.writeln "Compiling #{src} -> #{dest}"
				text = grunt.file.read src
				{ code, map } = mason.compile text,
					fileName: src
					outFileName: dest
				grunt.file.write dest, code
				grunt.file.write "#{dest}.map", map

				grunt.log.writeln 'done'


			###
			# Concat specified files.
			src =
				fileGroup.src.filter (filepath) ->
					# Warn on and remove invalid source files (if nonull was set).
					if grunt.file.exists filepath
						yes
					else
						grunt.log.warn "Source file '#{filepath} not found."
						no

				.map (filepath) ->
					# Read file source.
					grunt.file.read filepath

				.join grunt.util.normalizelf options.separator

			# Handle options.
			src += options.punctuation

			# Write the destination file.
			grunt.file.write file.dest, src

			# Print a success message.
			grunt.log.writeln "File '#{fileGroup.dest}' created."
			###
