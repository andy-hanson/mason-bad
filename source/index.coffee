{ type } = require './help/check'
lex = require './lex'
parse = require './parse'
compileSingle = require './compile-single'
Options = require './Options'

###
Compile a single file.
@param source [String]
@param options [Object?]
  Input to `new Options`.
@return [{ code, map }]
###
@compile = (source, options) ->
	type source, String, options, Object

	compileSingle source, new Options options

