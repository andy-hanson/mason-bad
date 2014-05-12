{ check, type } =  require '../help/check'
{ repeated } = require '../help/string'
Options = require '../Options'

###
Represents the context in which an Expression is compiled.
###
module.exports = class Context
	# @private
	constructor: (@_options, @_indent, @_localThis) ->
		type @_options, Options, @_indent, String, @_localThis, Boolean

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
	localThis: -> @_localThis

	###
	A new Context with `@indent()` containing another tab.
	###
	indented: ->
		new Context @options(), "#{@indent()}\t", @localThis()

	###
	A new context with `localThis` on.
	Called whenever `this` is bound to a local variable!
	###
	withLocalThis: ->
		new Context @options(), @indent(), yes

	###
	A new context with `localThis` off.
	Called within a function that does not preserve `this`.
	###
	withoutLocalThis: ->
		new Context @options(), @indent(), no

	###
	Context for the start of a file.
	@param options [Options]
	###
	@start: (options) ->
		new Context options, '', no
