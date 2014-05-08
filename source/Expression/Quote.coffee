Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Expression = require './Expression'

module.exports = class Quote extends Expression
	constructor: (@_pos, @_parts) ->
		type @_pos, Pos
		typeEach @_parts, Expression

	compile: (context) ->
		parts =
			@_parts.map (part) ->
				part.compile context
		interleave parts, ' + '
