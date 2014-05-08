{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Expression = require './Expression'

module.exports = class Call extends Expression
	constructor: (@_caller, @_arguments) ->
		type @_caller, Expression
		typeEach @_arguments, Expression

	pos: -> @_caller.pos()

	caller: -> @_caller
	arguments: -> @_arguments

	compile: (context) ->
		args =
			@_arguments.map (arg) ->
				arg.toNode context
		args =
			interleave args, ', '

		[ (@_caller.toNode context), '(', args, ')' ]
