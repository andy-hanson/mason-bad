{ mangle, needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ abstract, type, typeEach } = require '../help/check'
{ interleave, last, rightUnCons  } = require '../help/list'
Expression = require './Expression'

module.exports = class BlockBody extends Expression
	# @noDoc
	compile: ->
		throw new Error "Should not be called!"

	makeRes: (context) ->
		abstract()

	@List: (pos, lines) ->
		new ListBody pos, lines

	@Dict: (pos, lines, keys) ->
		new DictBody pos, lines, keys

	@Plain: (pos, lines) ->
		new PlainBody pos, lines

###
Block that returns a list.
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
Block that returns a dict.
###
class DictBody extends BlockBody
	# @noDoc
	constructor: (@_pos, @_lines, @_keys) ->
		type @_pos, Pos
		typeEach @_lines, Expression
		typeEach @_keys, String

	# @noDoc
	makeRes: (context, lineNodes) ->
		lines =
			@_lines.map (line) ->
				line.toNode context
		lines.push [ 'var res = ', (genObjectLiteral @_keys, context.indent()) ]

		lines: lines
		madeRes: yes

###
Block that returns the last line if it is a pure expression,
else returns nothing.
###
class PlainBody extends BlockBody
	# @noDoc
	constructor: (@_pos, @_lines) ->
		type @_pos, Pos
		typeEach @_lines, Expression

	# @noDoc
	makeRes: (context) ->
		lines =
			@_lines.map (line) ->
				line.toNode context

		if (last @_lines)?.pure()
			[ leadIn, finish ] =
				rightUnCons lines

			leadIn.push [ 'var res = ', finish ]
			lines: leadIn
			madeRes: yes
		else
			lines: lines
			madeRes: no
