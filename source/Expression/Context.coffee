{ check, type } =  require '../help/check'
{ repeated } = require '../help/string'
Options = require '../Options'

###
Represents the context in which an Expression is compiled.
###
module.exports = class Context
	# Constructs from options, file name, and indent string.
	constructor: (@_options, @_indent) ->
		type @_options, Options, @_indent, String

	###
	The Options that were sent to the compiler.
	###
	options: -> @_options

	###
	Current indentation. A string of many tabs.
	@return [String]
	###
	indent: -> @_indent

	###
	A new Context with `@indent()` containing another tab.
	###
	indented: ->
		new Context @options(), "#{@indent()}\t"
