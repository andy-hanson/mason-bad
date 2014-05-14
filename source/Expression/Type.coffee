{ type } = require '../help/check'
Context = require './Context'
Expression = require './Expression'

###
Represents the type of a variable.
Simply wraps around an expression that is the type.
###
module.exports = class Type extends Expression
	###
	@param _value [Expression]
	###
	constructor: (@_value) ->
		type @_value, Expression

	# @noDoc
	pos: -> @_value.pos()

	###
	Generate a type test.
	@param context [Context]
	@param tested [Expression]
	@return [Chunk]
	###
	toTest: (context, tested) ->
		type context, Context, tested, Expression

		tipe =
			@_value.toNode context
		test =
			tested.toNode context

		[ tipe, '["subsumes?"](', test, ')' ]

	###
	Generate a type assertion.
	@param context [Context]
	@param checked [Expression]
	@param name [String]
	@return [Chunk]
	###
	toCheck: (context, checked, name) ->
		type context, Context, checked, Expression, name, String

		tipe =
			@_value.toNode context
		chek =
			checked.toNode context

		[ tipe, '["!subsumes"](', chek, ', "', name, '")' ]
