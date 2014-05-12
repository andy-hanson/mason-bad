Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

###
Expression for the current object.
###
module.exports = class This extends Expression
	###
	@param _pos [Pos]
	###
	constructor: (@_pos) ->
		type @_pos, Pos

	# @noDoc
	compile: (context) ->
		if context.localThis()
			'_this'
		else
			'this'
