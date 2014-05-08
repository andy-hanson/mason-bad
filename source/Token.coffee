{ nameKinds, keywords } = require './compile-help/language'
{ abstract, check, type, typeEach } = require './help/check'
{ last } = require './help/list'
{ repeated } = require './help/string'
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

class Keyword extends Token
	constructor: (@_pos, @_kind) ->
		type @_pos, Pos, @_kind, String
		check @_kind in keywords

	kind: -> @_kind

	show: ->
		x =
			if @_kind == '\n'
				'\\n'
			else
				@_kind
		"<#{x}>"


class Use extends Token
	constructor: (@_pos, @_nLeadingDots, @_parts) ->
		type @_nLeadingDots, Number
		typeEach @_parts, String
		console.log @_parts
		check @_parts.length == 1, "Destructuring use is TODO"

	localName: ->
		last @_parts

	path: ->
		prefix =
			switch @_nLeadingDots
				when 0
					''
				when 1
					'./'
				else
					repeated '../', @_nLeadingDots - 1

		prefix + @_parts[0]

	show: ->
		"use #{@path()}" ##{@_nLeadingDots}|#{@_parts}"


module.exports =
	Group: Group
	Keyword: Keyword
	Literal: Literal
	Name: Name
	NumberLiteral: NumberLiteral
	StringLiteral: StringLiteral
	Token: Token
	Use: Use

	keyword: (kind) -> (token) ->
		token instanceof Keyword and token.kind() == kind

	dotName: (token) ->
		token instanceof Name and token.kind() == '.x'