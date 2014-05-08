lex = require './lex'
parse = require './parse'
compileSingle = require './compile-single'
Options = require './Options'

@compile = (string, options) ->
	options = new Options options

	(compileSingle string, options)

