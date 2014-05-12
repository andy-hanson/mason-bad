Pos = require '../compile-help/Pos'
{ mangle } = require '../compile-help/JavaScript-syntax'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
AssignSingle = require './AssignSingle'
Expression = require './Expression'
JS = require './JS'
Member = require './Member'
TypedVariable = require './TypedVariable'

###
Represents object destructuring assignment.

In:

	a b = c

`names` and `a` and `b`, and `value` is `c`.
###
module.exports = class AssignDestructure extends Expression
	###
	@param _pos [Pos]
	@param _vars [Array<TypedVariable>]
	@param _value [Expression]
	###
	constructor: (@_pos, @_vars, @_value, @_isMutate) ->
		type @_pos, Pos
		typeEach @_vars, TypedVariable
		type @_value, Expression, @_isMutate, Boolean

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		val =
			@_value.toNode context.indented()

		refDef =
			[ 'var _ref =\n', context.indent(), '\t', val ]

		refAccess =
			new JS @pos(), '_ref'

		assigns =
			@_vars.map (_var) =>
				refMember =
					new Member @pos(), refAccess, _var.var().name()
				assign =
					new AssignSingle @pos(), _var, refMember, @_isMutate

				assign.toNode context

		nl =
			[ ';\n', context.indent() ]

		[ refDef, nl, (interleave assigns, nl) ]
