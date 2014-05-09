{ groupKinds, nameKinds, keywords } = require './compile-help/language'
{ abstract, check, type, typeEach } = require './help/check'
{ last } = require './help/list'
{ repeated } = require './help/string'
Pos = require './compile-help/Pos'

###
The result of tokenization.
A single syntactical unit or group of them.
###
class Token
	###
	Source position of this token.
	@return [Pos]
	###
	pos: -> @_pos

	# @noDoc
	toString: ->
		"#{@show()}@#{@pos()}"

	###
	Representation of this Token (for debugging).
	@abstract
	###
	show: ->
		abstract()

###
A Token which represents plain data.
###
class Literal extends Token
	###
	JavaScript representation of this Literal.
	@abstract
	###
	toJS: ->
		abstract()

	# @noDoc
	show: ->
		@toJS()

###
A string with no interpolation.
A part of quote `Group`s.
###
class StringLiteral extends Literal
	###
	@param _pos [Pos]
	@param _value [String]
	###
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, String

	# @noDoc
	toJS: ->
		"\"#{@_value}\""

###
A floating-point number.
###
class NumberLiteral extends Literal
	###
	@param _pos [Pos]
	@param _value [String]
	###
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, String

	# @noDoc
	toJS: ->
		# Encase in parentheses to avoid `1.sin` sort of error.
		"(#{@_value})"

###
Javascript code passed through directly.
###
class JSLiteral extends Literal
	###
	@param _pos [Pos]
	@param _text [String]
	###
	constructor: (@_pos, @_text) ->
		type @_pos, Pos, @_text, String

	# @noDoc
	toJS: ->
		@_text

###
Contains many sub-`Token`s.
May be a parenthesied expression, a quote, or an indented block.
###
class Group extends Token
	###
	@param _pos [Pos]
	@param _kind [String]
	@param _body [Array<Token>]
	###
	constructor: (@_pos, @_kind, @_body) ->
		type @_pos, Pos
		check @_kind in groupKinds
		typeEach @_body, Token

	###
	Representation of the kind of group this is.
	A member of groupKinds from `./compile-help/language`.
	###
	kind: -> @_kind

	###
	The tokens contained in this group.
	###
	body: -> @_body

	# @noDoc
	show: ->
		"#{@_kind}<#{@_body}>"


###
An ordinary name.
There are many kinds of names:
###
class Name extends Token
	###
	@param _pos [Pos]
	@param _text [String]
	@param _kind [String]
	###
	constructor: (@_pos, @_text, @_kind) ->
		type @_pos, Pos, @_text, String
		check @_kind in nameKinds

	###
	Letters of this name.
	Does not include leading character.
	`x`.text() is `x`.
	`:String`.text() is `String`.
	###
	text: -> @_text

	###
	Kind of name this is.
	`x` for a plain name.
	`.x` for member access (`.y` in `x.y`).
	`:x` for a type (as in `x:String`).
	`@x` for this-member access (as in `@myProperty`).
	###
	kind: -> @_kind

	# @noDoc
	show: ->
		"Name(#{@_text}, #{@_kind})"

###
A reserved name or special character.
###
class Keyword extends Token
	###
	@param _pos [Pos]
	@param _kind [String]
	###
	constructor: (@_pos, @_kind) ->
		type @_pos, Pos
		check @_kind in keywords

	###
	The special thing this is.
	A member of `keywords` from `./compile-help/language`.
	###
	kind: -> @_kind

	# @noDoc
	show: ->
		x =
			if @_kind == '\n'
				'\\n'
			else
				@_kind
		"<#{x}>"


###
Just the first part of a `use` statement.
Eg from `use ..x for y`, this would just be `..x`.
###
class Use extends Token
	###
	@param _pos [Pos]
	@param _nLeadingDots [Number]
	  Number of periods at the start.
	@param _parts [Array<String>]
	  Parts separated by periods.
	###
	constructor: (@_pos, @_nLeadingDots, @_parts) ->
		type @_nLeadingDots, Number
		typeEach @_parts, String
		check @_parts.length == 1, "Dotted delving use is TODO"

	###
	Name of local variable derived from this (if it is not destructured).
	###
	localName: ->
		last @_parts

	###
	If this is a relative use, the relative path.
	Otherwise, the name of the module used.
	###
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

	# @noDoc
	show: ->
		"use #{@path()}" ##{@_nLeadingDots}|#{@_parts}"


module.exports =
	Group: Group
	Keyword: Keyword
	Literal: Literal
	Name: Name
	NumberLiteral: NumberLiteral
	StringLiteral: StringLiteral
	JSLiteral: JSLiteral
	Token: Token
	Use: Use

	group: (kind) -> (token) ->
		token instanceof Group and token.kind() == kind

	keyword: (kind) -> (token) ->
		token instanceof Keyword and token.kind() == kind

	dotName: (token) ->
		token instanceof Name and token.kind() == '.x'