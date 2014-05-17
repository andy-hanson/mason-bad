{ cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Break extends Expression
	constructor: (@_pos) ->
		type @_pos, Pos

	compile: (context) ->
		'break exitLoop'

	returnable: ->
		no

	returner: ->
		cFail @pos(), 'Tried to return break'
