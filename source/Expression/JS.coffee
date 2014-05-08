Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'


module.exports = class JS extends Expression
	constructor: (@_pos, @_text) ->
		type @_pos, Pos, @_text, String

	compile: ->
		@_text
