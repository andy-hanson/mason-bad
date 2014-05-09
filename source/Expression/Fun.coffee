{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Block = require './Block'
Expression = require './Expression'

###
@todo
###
module.exports = class Fun extends Expression
	###
	@param _pos [Pos]
	@param _argumentNames [Array<String>]
	@param _body [Block]
	###
	constructor: (@_pos, @_argumentNames, @_block) ->
		type @_pos, Pos
		typeEach @_argumentNames, String
		type @_block, Block

	# @noDoc
	compile: (context) ->
		args =
			interleave (@_argumentNames.map mangle), ', '

		[ 'function(', args, ')\n', context.indent(), (@_block.toNode context) ]


