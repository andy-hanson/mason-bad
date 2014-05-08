{ abstract, check, type } = require './help/check'
{ nameKinds, keywords } = require './compile-help/language'
Pos = require './compile-help/Pos'

class Token
	pos: -> @_pos

	toString: ->
		@show()

class Literal extends Token
	###
	JavaScript representation of this Literal.
	@abstract
	###
	toJS: abstract

	show: ->
		@toJS()

class StringLiteral extends Literal
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, String

	toJS: ->
		"\"#{@_value}\""

class NumberLiteral extends Literal
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, String

	toJS: ->
		"(#{@_value})"


class Group extends Token
	constructor: (@_pos, @_kind, @_body) ->
		type @_pos, Pos, @_kind, String, @_body, Array

	kind: -> @_kind
	body: -> @_body

	show: ->
		"#{@_kind}<#{@_body}>"


###
A name.
###
class Name extends Token
	constructor: (@_pos, @_text, @_kind) ->
		type @_pos, Pos, @_text, String
		check @_kind in nameKinds

	text: -> @_text
	kind: -> @_kind

	show: ->
		"Name(#{@_text}, #{@_kind})"

class Special extends Token
	constructor: (@_pos, @_kind) ->
		type @_pos, Pos, @_kind, String
		check @_kind in keywords.special

	kind: -> @_kind

	show: ->
		x =
			if @_kind == '\n'
				'\\n'
			else
				@_kind
		"<#{x}>"


module.exports =
	Group: Group
	Name: Name
	Literal: Literal
	StringLiteral: StringLiteral
	NumberLiteral: NumberLiteral
	Special: Special
	Token: Token
	special: (kind) -> (token) ->
		token instanceof Special and token.kind() == kind
	dotName: (token) ->
		token instanceof Name and token.kind() == '.x'