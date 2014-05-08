{ check, type } =  require '../help/check'
{ repeated } = require '../help/string'
Options = require '../Options'

###
Represents the context of compiling an Expression.
###
module.exports = class Context
	# Constructs from options, file name, and indent string.
	constructor: (@_options, @_indent) ->
		type @_options, Options, @_indent, String

	options: -> @_options
	indent: -> @_indent

	###
	A new Context with `@indent()` containing `n` more tabs.
	###
	indented: (n = 1) ->
		check n > 0
		new Context @options(), "#{repeated '\t', n}#{@indent()}"