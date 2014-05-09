Pos = require '../compile-help/Pos'
{ mangle } = require '../compile-help/JavaScript-syntax'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
AssignSingle = require './AssignSingle'
Expression = require './Expression'
JS = require './JS'
Member = require './Member'

###
Represents object destructuring assignment.

In:

	a b = c

`names` and `a` and `b`, and `value` is `c`.
###
module.exports = class AssignDestructure extends Expression
	###
	@param _pos [Pos]
	@param _names [Array<String>]
	@param _value [Expression]
	###
	constructor: (@_pos, @_names, @_value) ->
		type @_pos, Pos
		typeEach @_names, String
		type @_value, Expression

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		val =
			@_value.toNode context.indented()

		ref =
			[ 'var _ref =\n', context.indent(), '\t', val ]

		assigns =
			@_names.map (name) =>
				la =
					new JS @pos(), '_ref'
				ma =
					new Member @pos(), la, name
				as =
					new AssignSingle @pos(), name, null, ma

				as.toNode context

		nl =
			[ ';\n', context.indent() ]

		[ ref, nl, (interleave assigns, nl) ]
