Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Assign extends Expression
	constructor: (@_pos, @_name, @_type, @_value) ->
		type @_pos, Pos, @_name, String
		type @_value, Expression

	name: -> @_name
	type: -> @_type
	value: -> @_value

	compile: (context) ->
		[ 'var ', @_name, ' = ', @_value.toNode context ]
