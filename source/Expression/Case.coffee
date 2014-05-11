Pos = require '../compile-help/Pos'
{ type, typeEach, typeExist } = require '../help/check'
{ interleave } = require '../help/list'
Block = require './Block'
BlockWrap = require './BlockWrap'
CasePart = require './CasePart'
Expression = require './Expression'
Local = require './Local'

###
Handles the `case` control structure.
###
module.exports = class Case extends Expression
	###
	@param _pos [Pos]
	@param _cased [Local]
	  Name of the thing being cased on.
	@param _parts [Array<CasePart>]
	  Possible case matches.
	@param _else [Block]
	  Optional fallback. If missing the case will throw an error on fallback.
	###
	constructor: (@_pos, @_cased, @_parts, @_else) ->
		type @_pos, Pos, @_cased, Local
		typeEach @_parts, CasePart
		typeExist @_else, Block

	# @noDoc
	compile: (context) ->
		(new BlockWrap @pos(), new CaseBlock @).toNode context

###
@private
Block used when compiling a Case.
###
class CaseBlock extends Block
	# @noDoc
	constructor: (@_case) ->

	# @noDoc
	pos: ->
		@_case.pos()

	# @noDoc
	compile: (context) ->
		parts =
			@_case._parts.map (part) =>
				part.toTest context, @_case._cased
		parts =
			interleave parts, [ '\n', context.indent() ]
		elze =
			if @_case._else?
				@_case._else.toNode context
			else
				'throw new Error("Case failed")'

		[ parts, '\n', context.indent(), elze ]
