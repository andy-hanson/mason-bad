Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Assignable = require './Assignable'

###
JavaScript literal.
###
module.exports = class JS extends Assignable
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

	# @noDoc
	assignableCode: ->
		@_text