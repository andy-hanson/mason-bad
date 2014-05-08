Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Null extends Expression
	constructor: (@_pos) ->
		type @_pos, Pos

	compile: ->
		'null'

