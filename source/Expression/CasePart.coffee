Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Block = require './Block'
CaseTest = require './CaseTest'
Expression = require './Expression'

###
A single possible match in a case expression.
Includes both the test and the block that ensues when the test passes.
###
module.exports = class CasePart extends Expression
	###
	@param _test [CaseTest]
	@param _block [Block]
	###
	constructor: (@_test, @_block) ->
		type @_test, CaseTest, @_block, Block

	# @noDoc
	pos: ->
		@_test.pos()

	###
	Generates the test (and if the test passes the block will be called).
	`cased` is passed in by the `Case` I am a part of.
	@return [Chunk]
	###
	compile: (context) ->
		test =
			@_test.toNode context
		blockContext =
			context.indented()
		block =
			@_block.toNode blockContext

		[	'if (', test, ')\n',
			context.indent(), '{\n',
			blockContext.indent(), block, '\n',
			context.indent(), '}' ]

