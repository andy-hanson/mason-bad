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

	a:A b:B~c = d

`nameToVar` will be:

	a: TypedVariable(a, A)
	c: TypedVariable(b, B)
###
module.exports = class AssignDestructure extends Expression
	###
	@param _pos [Pos]
	@param _namesToVars [Dict<String, TypedVariable>]
	@param _value [Expression]
	@param _isMutate [Boolean]
	###
	constructor: (@_pos, @_namesToVars, @_value, @_isMutate) ->
		type @_pos, Pos
		for key of @_namesToVars
			type @_namesToVars[key], TypedVariable
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
			(Object.keys @_namesToVars).map (name) =>
				_var =
					@_namesToVars[name]
				refMember =
					new Member @pos(), refAccess, name #_var.var().name()
				assign =
					new AssignSingle @pos(), _var, refMember, @_isMutate

				assign.toNode context

		nl =
			[ ';\n', context.indent() ]

		[ refDef, nl, (interleave assigns, nl) ]
