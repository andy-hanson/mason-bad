Pos = require '../compile-help/Pos'
{ abstract, check, type, typeEach, typeExist } = require '../help/check'
{ interleave } = require '../help/list'
BlockBody = require './BlockBody'
Context = require './Context'
Expression = require './Expression'
Local = require './Local'
TypedVariable = require './TypedVariable'
Type = require './Type'

###
A bunch of statements within `{}`, possibly having a `return`.
So, either the body of a function, or part of a BlockWrap.
Figures out whether it should return an object, list, or expression.
Does not include type checks; that's up to `Fun`.
###
module.exports = class Block extends Expression
	###
	@param _pos [Pos]
	@param _body [BlockBody]
	  Lines that write to `res`.
	@param _inLines [Array<Expression>]
	  Lines to execute as in-condition.
	@param _outLines [Array<Expression>]
	  Lines to execute as out-condition.
	###
	constructor: (@_pos, @_body, @_inLines, @_outLines) ->
		type @_pos, Pos, @_body, BlockBody
		typeEach @_inLines, Expression, @_outLines, Expression

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
		typeExist returnType, Type

		allLines = []

		@_inLines.forEach (line) ->
			allLines.push line.toNode context

		{ lines, madeRes } =
			@_body.makeRes context

		allLines.push lines...

		if returnType?
			tv = new TypedVariable (Local.res @pos()), returnType
			allLines.push tv.typeCheck context

		@_outLines.forEach (line) ->
			allLines.push line.toNode context

		if madeRes
			allLines.push [ 'return res' ]
		else
			# This may be inside a CasePart, in which case we'd need a return.
			allLines.push [ 'return' ]

		interleave allLines, [ ';\n', context.indent() ]
