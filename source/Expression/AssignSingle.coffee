Pos = require '../compile-help/Pos'
{ mangle } = require '../compile-help/JavaScript-syntax'
{ type } = require '../help/check'
Expression = require './Expression'
TypedVariable = require './TypedVariable'

###
Sets a single name to a value. Eg `a = b`.
###
module.exports = class AssignSingle extends Expression
	###
	@param _pos [Pos]
	@param _name [String]
	@param _type [Null]
	@param _value [Expression]
	###
	constructor: (@_pos, @_var, @_value, @_isMutate) ->
		type @_pos, Pos, @_var, TypedVariable
		type @_value, Expression, @_isMutate, Boolean

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		assignTo =
			@_var.var().assignableCode context, @_isMutate
		val =
			@_value.toNode context.indented()
		ass =
			[ assignTo, ' =\n', context.indent(), '\t', val ]

		check =
			if @_var.hasType()
				[ ';\n', context.indent(), @_var.typeCheck context ]
			else
				''

		[ ass, check ]

