{ okMemberName } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Member extends Expression
	constructor: (@_pos, @_object, @_memberName) ->
		type @_pos, Pos, @_object, Expression, @_memberName, String

	compile: (context) ->
		object =
			@_object.toNode context

		if okMemberName @_memberName
			[ object, '.', @_memberName ]
		else
			[ object, '["', @_memberName, '"]' ]
