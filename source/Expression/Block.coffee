{ mangle, needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ abstract, check, type, typeEach, typeExist } = require '../help/check'
{ interleave, interleavePlus, isEmpty, last, rightUnCons } =
	require '../help/list'
Context = require './Context'
Expression = require './Expression'
Local = require './Local'
TypedVariable = require './TypedVariable'

###
Creates an object literal for the given keys.
Eg for 'a' and '+', we get:

	{
		a: a,
		"+": _42
	}
###
genObjectLiteral = (keys, indent) ->
	nl = [ '\n', indent ]
	cnl =[ ',', nl, '\t' ]

	assigns =
		keys.map (key) ->
			if needsMangle key
				[ '"', key, '": ', mangle key ]
			else
				[ key, ': ', key ]
	parts =
		interleave assigns, cnl

	[ '{', nl, '\t', parts, nl, '}' ]


###
A bunch of statements within `{}`, possibly having a `return`.
So, either the body of a function, or part of a BlockWrap.
Figures out whether it should return an object, list, or expression.
###
module.exports = class Block extends Expression
	###
	@param _pos [Pos]
	@param _lines [Array<Expression>]
	@param _keys [Array<String>]
	  Object keys defined within this block.
	  Empty if this is not an object block.
	constructor: (@_pos, @_lines, @_keys) ->
		type @_pos, Pos
		typeEach @_lines, Expression
		typeEach @_keys, String
	###

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		@withReturnType context, null

	###
	Compile this block optionally with the given return type.
	@param context [Context]
	@param returnType [String?]
	###
	withReturnType: (context, returnType) ->
		type context, Context
		typeExist returnType, String

		{ lines, returnValue, alreadyMadeRes } =
			@_preReturn context

		if returnValue?
			if returnType?
				unless alreadyMadeRes
					lines.push [ 'var res = ', returnValue ]
				tv =
					new TypedVariable (new Local @pos(), 'res'), returnType
				lines.push tv.typeCheck context
				lines.push 'return res'
			else
				lines.push [ 'return ', returnValue ]

		interleave lines, [ ';\n', context.indent() ]

	###
	@private
	@return
	  lines [Array<Chunk>]
	    Lines to execute. They are not returned.
	  returnValue [Chunk?]
	    Value to return. If undefined, the function returns nothing.
	  alreadyMadeRes [Boolean]
	    Whether the function already wrote to `res`.
	###
	preReturn: (context) ->
		abstract()

	###
	@param pos [Pos]
	@param lines [Array<Expression>]
	###
	@List: (pos, lines) ->
		new ListBlock pos, lines

	###
	@param pos [Pos]
	@param lines [Array<Expresson>]
	@param keys [Array<String>]
	###
	@Dict: (pos, lines, keys) ->
		new DictBlock pos, lines, keys

	###
	@param pos [Pos]
	@param lines [Array<Expression>]
	###
	@Plain: (pos, lines) ->
		new PlainBlock pos, lines

###
Block that returns a list.
###
class ListBlock extends Block
	# @noDoc
	constructor: (@_pos, @_lines) ->
		type @_pos, Pos
		typeEach @_lines, Expression

	# @noDoc
	_preReturn: (context) ->
		lines:
			[ 'var res = []' ].concat @_lines.map (line) ->
				line.toNode context
		returnValue:
			'res'
		alreadyMadeRes:
			yes

###
Block that returns a dict.
###
class DictBlock extends Block
	# @noDoc
	constructor: (@_pos, @_lines, @_keys) ->
		type @_pos, Pos
		typeEach @_lines, Expression
		typeEach @_keys, String

	# @noDoc
	_preReturn: (context, lineNodes) ->
		lines:
			@_lines.map (line) ->
				line.toNode context
		returnValue:
			genObjectLiteral @_keys, context.indent()

###
Block that returns the last line if it is a pure expression,
else returns nothing.
###
class PlainBlock extends Block
	# @noDoc
	constructor: (@_pos, @_lines) ->
		type @_pos, Pos
		typeEach @_lines, Expression

	# @noDoc
	_preReturn: (context) ->
		lineNodes =
			@_lines.map (line) ->
				line.toNode context

		if (last @_lines)?.pure()
			[ leadIn, finish ] =
				rightUnCons lineNodes

			lines:
				leadIn
			returnValue:
				finish
		else
			lines: lineNodes

