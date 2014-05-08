{ typeEach } = require '../help/check'
{ interleave, interleavePlus, isEmpty } = require '../help/list'
Expression = require './Expression'

genObjectLiteral = (keys, indent) ->
	nl = "\n#{indent}"
	cnl = ',' + nl + '\t'

	assigns =
		for key in keys
			[ key, ': ', key ]
	parts =
		interleave assigns, cnl

	[ '{', nl, '\t', parts, nl, '}' ]

module.exports = class Block extends Expression
	constructor: (@_pos, @_lines, @_keys) ->
		typeEach @_lines, Expression
		typeEach @_keys, String

	compile: (context) ->
		lines =
			for line in @_lines
				line.toNode context

		newIndent =
			context.indent() + '\t'

		unless isEmpty @_keys
			lines.push genObjectLiteral @_keys, newIndent

		lines[lines.length - 1] = [ 'return ', lines[lines.length - 1] ]

		x = interleave lines, [ ';\n', newIndent ]

		[ '{\n', newIndent, x, '\n', context.indent(), '}' ]

