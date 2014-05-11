{ check, type } =  require '../help/check'
{ repeated } = require '../help/string'
Options = require '../Options'

###
Represents the context in which an Expression is compiled.
###
module.exports = class Context
	# @private
	constructor: (@_options, @_indent, @_boundThis) ->
		type @_options, Options, @_indent, String, @_boundThis, Boolean

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
	Whether we are using `_this` (a local variable) rather than `this`.
	###
	boundThis: -> @_boundThis

	###
	A new Context with `@indent()` containing another tab.
	###
	indented: ->
		new Context @options(), "#{@indent()}\t", @boundThis()

	###
	A new context with `boundThis` on.
	Called whenever `this` is bound to a local variable!
	###
	withBoundThis: ->
		new Context @options(), @indent(), yes

	###
	A new context with `boundThis` off.
	Called within a function that does not preserve `this`.
	###
	withoutBoundThis: ->
		new Context @options(), @indent(), no

	###
	Context for the start of a file.
	@param options [Options]
	###
	@start: (options) ->
		new Context options, '', no
