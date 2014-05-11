{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type, typeEach, typeExist } = require '../help/check'
{ interleave, interleavePlus } = require '../help/list'
Block = require './Block'
BlockWrap = require './BlockWrap'
Expression = require './Expression'
TypedVariable = require './TypedVariable'

###
A function. All functions in Mason are anonymous.
###
module.exports = class Fun extends Expression
	###
	@param _pos [Pos]
	@param _returnType [String]
	@param _arguments [Array<TypedVariable>]
	@param _body [Block]
	@param _preserveThis [Boolean]
	###
	constructor: (@_pos, @_returnType, @_arguments, @_block, @_preserveThis) ->
		type @_pos, Pos
		typeExist @_returnType, String
		typeEach @_arguments, TypedVariable
		type @_block, Block, @_preserveThis, Boolean

	# @noDoc
	compile: (context) ->
		if @_preserveThis
			if context.boundThis()
				@compilePlain context
			else
				block =
					Block.Plain @pos(), [ @ ]
				(new BlockWrap @pos(), block).compile context
		else
			@compilePlain context.withoutBoundThis()

	# @private
	compilePlain: (context) ->
		argNodes =
			@_arguments.map (arg) ->
				arg.var().toNode context
		args =
			interleave argNodes, ', '
		insideContext =
			context.indented()
		checks =
			@_arguments.filter (arg) ->
				arg.hasType()
			.map (arg) ->
				arg.typeCheck insideContext
		cs =
			interleavePlus checks, [ ';\n', insideContext.indent() ]
		block =
			@_block.withReturnType insideContext, @_returnType

		[	'function(', args, ')\n',
			context.indent(), '{\n', insideContext.indent(),
			cs,
			block,
			'\n', context.indent(), '}' ]
