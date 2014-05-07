module.exports = (grunt) ->
	grunt.initConfig
		pkg:
			grunt.file.readJSON 'package.json'

		clean:
			all: [ 'doc', 'node_modules' ]

		codo:
			options:
				inputs: [ 'source' ]
				output: 'doc'

		coffee:
			dev:
				expand: yes
				flatten: yes
				cwd: 'source'
				src: [ '*.coffee' ]
				dest: 'js'
				ext: '.js'

				bare: yes
				sourceMap: yes


		coffeelint:
			app: [ 'source/**/*.coffee' ]
			options:
				camel_case_classes:
					level: 'error'
				indentation:
					value: 1
					level: 'error'
				max_line_length:
					value: 80
					level: 'error'
				no_plusplus:
					level: 'error'
				no_tabs:
					level: 'ignore'
				no_throwing_strings:
					level: 'error'
				no_trailing_semicolons:
					level: 'error'
				no_trailing_whitespace:
					level: 'error'

	(require 'load-grunt-tasks') grunt

	grunt.registerTask 'default', [
		'codo',
		'coffeelint',
		'coffee'
	]