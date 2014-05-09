Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Expression = require './Expression'

###
Creates a string out of its parts. Eg `"One plus one is {+ 1 1}."`
###
module.exports = class Quote extends Expression
	###
	@param _pos [Pos]
	@param _parts [Array<Expression>]
	  Each of these will be concatenated into a string.
	  (`toString()` is called implicitly.)
	###
	constructor: (@_pos, @_parts) ->
		type @_pos, Pos
		typeEach @_parts, Expression

	# @noDoc
	compile: (context) ->
		parts =
			@_parts.map (part) ->
				part.compile context
		interleave parts, ' + '
