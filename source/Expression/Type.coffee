Pos = require '../compile-help/Pos'
{ abstract, type } = require '../help/check'
Context = require './Context'
Expression = require './Expression'

###
Represents the type of a variable.
Simply wraps around an expression that is the type.
###
module.exports = class Type extends Expression
	###
	Generate a type test.
	@param context [Context]
	@param tested [Expression]
	@return [Chunk]
	###
	toTest: (context, tested) ->
		abstract()

	###
	Generate a type assertion.
	@param context [Context]
	@param checked [Expression]
	@param name [String]
	@return [Chunk]
	###
	toCheck: (context, checked, name) ->
		abstract()

	@Default: (pos) ->
		new Type.DefaultType pos

	@Expression: (value) ->
		new Type.ExpressionType value

	@Void: (pos) ->
		new Type.VoidType pos

class Type.DefaultType extends Type
	constructor: (@_pos) ->
		type @_pos, Pos

	# @noDoc
	toCheck: (context, checked, name) ->
		chek =
			checked.toNode context

		[ 'if (', chek, ' == null) throw new Error("', name, ' is undefined")' ]

class Type.ExpressionType extends Type
	###
	@param _value [Expression]
	###
	constructor: (@_value) ->
		type @_value, Expression

	# @noDoc
	pos: -> @_value.pos()

	# @noDoc
	toTest: (context, tested) ->
		type context, Context, tested, Expression

		tipe =
			@_value.toNode context
		test =
			tested.toNode context

		[ tipe, '["subsumes?"](', test, ')' ]

	# @noDoc
	toCheck: (context, checked, name) ->
		type context, Context, checked, Expression, name, String

		tipe =
			@_value.toNode context
		chek =
			checked.toNode context

		[ tipe, '["!subsumes"](', chek, ', "', name, '")' ]

class Type.VoidType extends Type
	constructor: (@_pos) ->
