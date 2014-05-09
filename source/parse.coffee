{ cCheck, cFail } = require './compile-help/check'
{ check, type, typeEach } = require './help/check'
{ isEmpty, rightUnCons, splitWhere, trySplitOnceWhere, unCons } =
	require './help/list'
E = require './Expression'
Pos = require './compile-help/Pos'
T = require './Token'

###
@private
The Parser is a class so that it can keep the @_pos as data while running.
###
class Parser
	###
	Makes a new Parser.
	###
	constructor: ->
		@_pos =
			Pos.start()

	###
	Parses the whole file.
	###
	all: (tokens) ->
		new E.BlockWrap Pos.start(), @block tokens

	###
	Parses the contents of a block.
	The caller must determine whether it will be in a BlockWrap or Fun.
	@return [Block]
	###
	block: (tokens) ->
		typeEach tokens, T.Token

		lines =
			(splitWhere tokens, T.keyword '\n').filter (line) ->
				not isEmpty line
		lineExprs = []
		allKeys = []
		lines.forEach (line) =>
			{ content, newKeys } = @line line
			lineExprs.push content
			allKeys.push newKeys...

		new E.Block tokens[0].pos(), lineExprs, allKeys

	###
	Parses a pure expression.
	@return [Expression]
	###
	expression: (tokens) ->
		typeEach tokens, T.Token

		parts =
			@expressionParts tokens

		if isEmpty parts
			E.null @_pos
		else
			[ e0, rest ] =
				unCons parts

			if isEmpty rest
				e0
			else
				new E.Call e0, rest

	###
	Parses the components of an expression.
	Eg `a.b (c d) e.f` has 3 parts: `a.b`, `(c d)`, and `e.f`.
	@return [Array<Expression>]
	###
	expressionParts: (tokens) ->
		typeEach tokens, T.Token

		parts = [ ]

		tokens.forEach (token) =>
			x =
				if T.dotName token
					if (popped = parts.pop())?
						new E.Member token.pos(), popped, token.text()
					else
						@unexpected token
				else
					@soloExpression token

			parts.push x

		parts

	fun: (tokens) ->
		[ argTokens, block ] =
			rightUnCons tokens

		args =
			argTokens.map (token) =>
				@name token

		cCheck ((T.group '→') block), @_pos, ->
			"Function open up to indented block, not #{block}"

		new E.Fun @_pos, args, @block block.body()

	###
	Parses a single line within a block.
	May be an assignment or pure expression.
	Returned `newKeys` are keys to add to this block's object.
	@return [{ content:Expression, newKeys:Array<String> }]
	###
	line: (tokens) ->
		isAssign = (x) ->
			((T.keyword '=') x) or (T.keyword '. ') x

		if tokens[0] instanceof T.Use
			content: @use tokens
			newKeys: [ ]

		else if (x = trySplitOnceWhere tokens, isAssign)?
			[ nameTokens, assigner, valueTokens ] = x

			@_pos = assigner.pos()

			names =
				for t in nameTokens
					@name t
			value =
				@expression valueTokens

			content:
				switch names.length
					when 0
						cFail @_pos, 'Assign to nothing'
					when 1
						new E.AssignSingle @_pos, names[0], null, value
					else
						new E.AssignDestructure @_pos, names, value

			newKeys:
				if assigner.kind() == '. '
					names
				else
					[]

		else
			content: @expression tokens
			newKeys: []

	###
	Gets the text from what *ought* to be a `Name`.
	@return [String]
	###
	name: (token) ->
		cCheck token instanceof T.Name, token.pos(), ->
			"Expected name, got #{token}"
		token.text()

	###
	Parses a single token which *should* be a pure expression of its own.
	###
	soloExpression: (token) ->
		type token, T.Token

		switch token.constructor
			when T.Name
				if token.kind() == 'x'
					new E.LocalAccess token.pos(), token.text()
				else
					fail()

			when T.Group
				@_pos = token.pos()
				body = token.body()

				switch token.kind()
					when '|'
						@fun body
					when '('
						@expression body
					when '→'
						new E.BlockWrap @_pos, @block body
					when '"'
						new E.Quote @_pos, body.map (part) =>
							@soloExpression part
					else
						fail()

			else
				if token instanceof T.Literal
					new E.JS token.pos(), token.toJS()
				else
					@unexpected token

	###
	Throws a compiler error when a bad token is encountered.
	###
	unexpected: (token) ->
		cFail token.pos(), "Unexpected #{token}"

	###
	Parses a `use` line.
	@return [AssignSingle | AssignDestructure]
	###
	use: (tokens) ->
		use = tokens[0]
		check use instanceof T.Use

		used =
			new E.Require use.pos(), use.path()

		if tokens.length == 1
			name =
				use.localName()

			new E.AssignSingle use.pos(), name, null, used
		else
			[ _, _for, whatFor... ] = tokens
			cCheck ((T.keyword 'for') _for), _for.pos(), ->
				"Expected 'for', got #{_for}"

			forThese =
				whatFor.map (x) ->
					cCheck (x instanceof T.Name and x.kind() == 'x'), x.pos(), ->
						"Expected local name, got #{x}"
					x.text()

			new E.AssignDestructure use.pos(), forThese, used

###
Finds the `Expression` that the `tokens` represent.
@param tokens [Array<Token>]
@return [Expression]
###
module.exports = parse = (tokens) ->
	type tokens, Array
	(new Parser).all tokens
