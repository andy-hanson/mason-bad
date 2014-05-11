{ needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Assignable = require './Assignable'
Expression = require './Expression'

###
Accesses a member of an object.
###
module.exports = class Member extends Assignable
	###
	@param _pos [Pos]
	@param _object [Expression]
	@param _member [String]
	###
	constructor: (@_pos, @_object, @_name) ->
		type @_pos, Pos, @_object, Expression, @_name, String

	# @noDoc
	name: -> @_name

	# @noDoc
	compile: (context) ->
		access =
			if needsMangle @_name
				[ '["', @_name, '"]' ]
			else
				[ '.', @_name ]

		[ (@_object.toNode context), access ]

	# @noDoc
	assignableCode: (context) ->
		@compile context
