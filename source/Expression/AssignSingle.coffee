Pos = require '../compile-help/Pos'
{ mangle } = require '../compile-help/JavaScript-syntax'
{ type } = require '../help/check'
Expression = require './Expression'

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
	constructor: (@_pos, @_name, @_type, @_value) ->
		type @_pos, Pos, @_name, String
		type @_value, Expression

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		val = @_value.toNode context.indented()
		mangled = mangle @_name
		[ 'var ', mangled, ' =\n', context.indent(), '\t', val ]
