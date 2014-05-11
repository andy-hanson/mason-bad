Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Block = require './Block'
Expression = require './Expression'

###
Wraps a block in a function, then calls that function.
This keeps locals defined in the block local to it.
###
module.exports = class BlockWrap extends Expression
	###
	@param _pos [Pos]
	@param _block [Block]
	###
	constructor: (@_pos, @_block) ->
		type @_pos, Pos, @_block, Block

	# @noDoc
	compile: (context) ->
		blockContext =
			context.indented().withBoundThis()
		block =
			@_block.toNode blockContext

		[ arg, closer ] =
			if context.boundThis()
				[ '', '' ]
			else
				[ '_this', 'this' ]


		[	'(function(', arg, ')\n',
			context.indent(), '{\n',
			blockContext.indent(), block, '\n',
			context.indent(), '})(', closer, ')' ]
