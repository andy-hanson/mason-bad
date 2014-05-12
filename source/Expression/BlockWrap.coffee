Pos = require '../compile-help/Pos'
{ type, typeExist } = require '../help/check'
{ interleave } = require '../help/list'
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
	constructor: (@_pos, @_block, @_othArgName, @_othArgVal) ->
		type @_pos, Pos, @_block, Block
		typeExist @_othArgName, String, @_othArgVal, Expression

	# @noDoc
	compile: (context) ->
		blockContext =
			context.indented().withLocalThis()
		block =
			@_block.toNode blockContext

		argNames = []
		argVals = []

		unless context.localThis()
			argNames.push '_this'
			argVals.push 'this'
		if @_othArgName?
			argNames.push @_othArgName
			argVals.push @_othArgVal.toNode context
		argNames =
			interleave argNames, ', '
		argVals =
			interleave argVals, ', '

		[	'(function(', argNames, ')\n',
			context.indent(), '{\n',
			blockContext.indent(), block, '\n',
			context.indent(), '})(', argVals, ')' ]
