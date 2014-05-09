{ needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

###
Accesses a member of an object.
###
module.exports = class Member extends Expression
	###
	@param _pos [Pos]
	@param _object [Expression]
	@param _member [String]
	###
	constructor: (@_pos, @_object, @_member) ->
		type @_pos, Pos, @_object, Expression, @_member, String

	# @noDoc
	compile: (context) ->
		access =
			if needsMangle @_member
				[ '["', @_member, '"]' ]
			else
				[ '.', @_member ]

		[ (@_object.toNode context), access ]
