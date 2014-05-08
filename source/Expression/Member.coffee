Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Member extends Expression
	constructor: (@_pos, @_object, @_memberName) ->
		type @_pos, Pos, @_object, Expression, @_memberName, String

	compile: (context) ->
		[ (@_object.toNode context), '.', @_memberName ]
