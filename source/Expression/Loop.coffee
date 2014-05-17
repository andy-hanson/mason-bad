{ cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Block = require './Block'
Expression = require './Expression'

module.exports = class Loop extends Expression
	constructor: (@_pos, @_body) ->
		type @_pos, Pos, @_body, Block

	compile: (context) ->
		blockContext =
			context.indented()
		body =
			@_body.toVoid context.indented(), @pos()

		[	'exitLoop: while (true)\n',
			context.indent(), '{\n',
			blockContext.indent(), body, '\n',
			context.indent(), '}' ]

	returnable: ->
		no

	returner: ->
		cFail @pos(), 'Non-Void block can not end in loop.'