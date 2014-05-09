{ mangle, needsMangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave, interleavePlus, isEmpty, last } = require '../help/list'
Expression = require './Expression'

###
Creates an object literal for the given keys.
Eg for 'a' and '+', we get:

	{
		a: a,
		"+": _42
	}
###
genObjectLiteral = (keys, indent) ->
	nl = "\n#{indent}"
	cnl = ',' + nl + '\t'

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
	###
	constructor: (@_pos, @_lines, @_keys) ->
		type @_pos, Pos
		typeEach @_lines, Expression
		typeEach @_keys, String

	# @noDoc
	pure: ->
		no

	# @noDoc
	compile: (context) ->
		newContext =
			context.indented()

		lines =
			for line in @_lines
				line.toNode newContext

		if not isEmpty @_keys
			lines.push [ 'return ', (genObjectLiteral @_keys, newContext.indent()) ]

		else if (last @_lines).pure()
			lines[lines.length - 1] = [ 'return ', lines[lines.length - 1] ]
		#else
		#	@lines.push 'return null'

		x = interleave lines, [ ';\n', newContext.indent() ]

		[ '{\n', newContext.indent(), x, '\n', context.indent(), '}' ]

