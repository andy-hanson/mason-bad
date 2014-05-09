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
		block =
			@_block.compile context

		[ '(function()\n', context.indent(), block, ')()' ]
