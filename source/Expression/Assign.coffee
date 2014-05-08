Pos = require '../compile-help/Pos'
{ mangle } = require '../compile-help/JavaScript-syntax'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Assign extends Expression
	constructor: (@_pos, @_name, @_type, @_value) ->
		type @_pos, Pos, @_name, String
		type @_value, Expression

	pure: ->
		no

	name: -> @_name
	type: -> @_type
	value: -> @_value

	compile: (context) ->
		mangled = mangle @_name
		[ 'var ', mangled, ' = ', @_value.toNode context ]

