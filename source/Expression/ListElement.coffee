{ type } = require '../help/check'
Expression = require './Expression'

###
A single entry in a list.
###
module.exports = class ListElement extends Expression
	###
	@param _pos [Pos]
	@param _value [Expression]
	  Value to push to the list.
	###
	constructor: (@_pos, @_value) ->
		type @_value, Expression

	# @noDoc
	compile: (context) ->
		[ '_res.push(', (@_value.toNode context), ')' ]
