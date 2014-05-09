{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Expression = require './Expression'

###
Applies one expression to several others.
Calling with no arguments is done with a null argument, as in `doIt ()`.
###
module.exports = class Call extends Expression
	###
	@param _caller [Expression]
	@param _arguments [Array<Expression>]
	###
	constructor: (@_caller, @_arguments) ->
		type @_caller, Expression
		typeEach @_arguments, Expression

	# @noDoc
	pos: -> @_caller.pos()

	# @noDoc
	compile: (context) ->
		args =
			@_arguments.map (arg) ->
				arg.toNode context
		args =
			interleave args, ', '

		[ (@_caller.toNode context), '(', args, ')' ]
