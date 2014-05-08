{ typeEach } = require '../help/check'
{ interleave, interleavePlus, isEmpty, last } = require '../help/list'
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

	pure: ->
		no

	compile: (context) ->
		lines =
			for line in @_lines
				line.toNode context

		newIndent =
			context.indent() + '\t'

		unless isEmpty @_keys
			lines.push genObjectLiteral @_keys, newIndent

		if (last @_lines).pure()
			lines[lines.length - 1] = [ 'return ', lines[lines.length - 1] ]
		else
			lines.push 'return null'

		x = interleave lines, [ ';\n', newIndent ]

		[ '{\n', newIndent, x, '\n', context.indent(), '}' ]

