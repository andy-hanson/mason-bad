{ cFail } = require '../compile-help/check'
{ mangle, needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ abstract, check, type, typeEach } = require '../help/check'
{ interleave, isEmpty, last, rightUnCons  } = require '../help/list'
Expression = require './Expression'

###
The content of a block responsible for creating `res`.
Does not include type checks or conditions.
###
module.exports = class BlockBody extends Expression
	# @noDoc
	compile: ->
		throw new Error "Should not be called!"

	###
	Code that will write to 'res'
	@return [Array[Chunk]]
	###
	makeRes: (context) ->
		abstract()

	###
	@return Array[Chunk]
	###
	makeVoid: (context) ->
		abstract()

	###
	@param pos [Pos]
	@param lines [Array<Expression>]
	@return [ListBody]
	###
	@List: (pos, lines) ->
		new ListBody pos, lines

	###
	@param pos [Pos]
	@param lines [Array<Expression>]
	@param keys [Array<String>]
	  Non-empty list of dict keys.
	  (There should be a local assignment in `lines` corresponding to each.)
	@return [DictBody]
	###
	@Dict: (pos, lines, keys) ->
		new DictBody pos, lines, keys

	###
	@param pos [Pos]
	@param lines [Array<Expression>]
	@return [PlainBody]
	###
	@Plain: (pos, lines) ->
		new PlainBody pos, lines

###
Returns a list.
###
class ListBody extends BlockBody
	# @noDoc
	constructor: (@_pos, @_lines) ->
		type @_pos, Pos
		typeEach @_lines, Expression

	# @noDoc
	makeRes: (context) ->
		[ 'var res = []' ].concat @_lines.map (line) ->
			line.toNode context

	makeVoid: (context) ->
		cFail @pos(), "Block contains list entries and can not return Void"

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
Returns a dict.
###
class DictBody extends BlockBody
	# @noDoc
	constructor: (@_pos, @_lines, @_keys) ->
		type @_pos, Pos
		typeEach @_lines, Expression
		typeEach @_keys, String

	# @noDoc
	makeRes: (context) ->
		lines =
			@_lines.map (line) ->
				line.toNode context
		lines.push [ 'var res = ', (genObjectLiteral @_keys, context.indent()) ]

		lines

	makeVoid: (context) ->
		cFail @pos(), "Block contains dict keys and can not return Void."

###
Returns the last line if it is a pure expression, else returns `undefined`.
###
class PlainBody extends BlockBody
	# @noDoc
	constructor: (@_pos, @_lines) ->
		type @_pos, Pos
		typeEach @_lines, Expression

	# @noDoc
	makeRes: (context) ->
		if isEmpty @_lines
			cFail @pos(), 'Block is not tagged `:Void` but has no value to return'
		else
			[ leadIn, finish ] =
				rightUnCons @_lines

			lines = []
			lines.push (leadIn.map (line) -> line.toNode context)...

			res =
				if finish.returnable()
					finish.toNode context
				else
					lines.push finish.toNode context
					finish.returner context

			lines.push [ 'var res = ', res ]

			lines

	makeVoid: (context) ->
		@_lines.map (line) ->
			line.toNode context
