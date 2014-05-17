{ cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach, typeExist } = require '../help/check'
{ interleave } = require '../help/list'
Assign = require './AssignSingle'
Block = require './Block'
BlockWrap = require './BlockWrap'
CasePart = require './CasePart'
Expression = require './Expression'
Local = require './Local'
Type = require './Type'
TypedVariable = require './TypedVariable'

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
	constructor: (@_pos, @_cased, @_parts, @_else, @_isValue) ->
		type @_pos, Pos, @_cased, Expression
		typeEach @_parts, CasePart
		typeExist @_else, Block
		type @_isValue, Boolean

	# @noDoc
	compile: (context) ->
		block =
			new CaseBlock @
		if @_isValue
			wrap =
				new BlockWrap @pos(), block, '_', @_cased
			wrap.toNode context
		else
			_var = new TypedVariable (new Local @pos(), '_'), Type.Default @pos()
			ass = new Assign @pos(), _var, @_cased, no
			[ (ass.toNode context), ';\n', context.indent(), block.toNode context ]
			#block.toNode context

	isValue: -> @_isValue

	returnType: ->
		if @_isValue
			null
		else
			Type.Void @pos()

	returnable: ->
		@_isValue

	returner: ->
		cFail @pos(), "`case!` can not be returned. Did you mean `case`?"

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
		#outer = [ 'switch (true)
		partContext =
			context.indented()
		parts =
			@_case._parts.map (part) =>
				part.toPart partContext, @_case
		parts =
			interleave parts, [ '\n', partContext.indent() ]
		elseContext =
			partContext.indented()
		elze =
			if @_case._else?
				# todo: 'default'
				[ @_case._else.withReturnType elseContext, @_case.returnType() ]
			else
				'throw new Error("Case failed")'

		[	'switch (true)\n',
			context.indent(), '{\n',
			partContext.indent(), parts, '\n',
			partContext.indent(), 'default:\n',
			elseContext.indent(), elze, '\n',
			context.indent(), '}' ]
