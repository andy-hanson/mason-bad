Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

###
JavaScript literal.
###
module.exports = class JS extends Expression
	###
	@param _pos [Pos]
	@param _text [String]
	  JavaScript code.
	###
	constructor: (@_pos, @_text) ->
		type @_pos, Pos, @_text, String

	# @noDoc
	compile: ->
		@_text
