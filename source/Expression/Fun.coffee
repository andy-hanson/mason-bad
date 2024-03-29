{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type, typeEach, typeExist } = require '../help/check'
{ interleave, interleavePlus } = require '../help/list'
Block = require './Block'
BlockWrap = require './BlockWrap'
Expression = require './Expression'
TypedVariable = require './TypedVariable'
Type = require './Type'

###
A function. All functions in Mason are anonymous.
###
module.exports = class Fun extends Expression
	###
	@param _pos [Pos]
	@param _returnType [Type?]
	@param _arguments [Array<TypedVariable>]
	@param _body [Block]
	@param _preserveThis [Boolean]
	###
	constructor: (@_pos, @_returnType, @_arguments, @_block, @_preserveThis) ->
		type @_pos, Pos
		typeExist @_returnType, Type
		typeEach @_arguments, TypedVariable
		type @_block, Block, @_preserveThis, Boolean

	# @noDoc
	compile: (context) ->
		if @_preserveThis
			if context.localThis()
				@compilePlain context
			else
				block =
					Block.Plain @pos(), [ @ ]
				(new BlockWrap @pos(), block).compile context
		else
			@compilePlain context.withoutLocalThis()

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
			if context.options().checks 'type'
				checksList =
					@_arguments.filter (arg) ->
						arg.hasType()
					.map (arg) ->
						arg.typeCheck insideContext

				interleavePlus checksList, [ ';\n', insideContext.indent() ]
			else
				''
		block =
			@_block.withReturnType insideContext, @_returnType

		[	'function(', args, ')\n',
			context.indent(), '{\n', insideContext.indent(),
			checks,
			block,
			'\n', context.indent(), '}' ]
