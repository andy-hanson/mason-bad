{ cCheck } = require '../compile-help/check'
{ type, typeEach } = require '../help/check'
{ isEmpty, splitWhere,
	trySplitOnceWhere, unCons } =
	require '../help/list'
E = require '../Expression'
Pos = require '../compile-help/Pos'
T = require '../Token'

###
@private
###
class Parser
	constructor: ->
		@_pos =
			Pos.start()

	###
	@return [Block]
	###
	block: (tokens) ->
		typeEach tokens, T.Token

		if isEmpty tokens
			new E.Null @_pos
		else
			lines =
				splitWhere tokens, T.keyword '\n'
			lineExprs = []
			allKeys = []
			lines.forEach (line) =>
				{ content, newKeys } = @line line
				lineExprs.push content
				allKeys.push newKeys...

			new E.Block tokens[0].pos(), lineExprs, allKeys


	###
	@return [Expression]
	###
	expression: (tokens) ->
		typeEach tokens, T.Token

		parts =
			@expressionParts tokens

		if isEmpty parts
			new E.Null @_pos
		else
			[ e0, rest ] =
				unCons parts

			if isEmpty rest
				e0
			else
				new E.Call e0, rest

	###
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




	###
	@return [{ content:Expression, newKeys:Array<String> }]
	###
	line: (tokens) ->
		# It may be an assignment or plain expression.

		isAssign = (x) ->
			((T.keyword '=') x) or (T.keyword '. ') x

		if (x = trySplitOnceWhere tokens, isAssign)?
			[ nameTokens, assigner, valueTokens ] = x

			@_pos = assigner.pos()

			names =
				for t in nameTokens
					@name t
			value =
				@expression valueTokens

			content: new E.Assign assigner.pos(), names[0], null, value
			newKeys:
				if assigner.kind() == '. '
					names
				else
					[]

		else
			content: @expression tokens
			newKeys: []

	###
	@return [String]
	###
	name: (token) ->
		cCheck token instanceof T.Name, token.pos(), ->
			"Expected name, got #{token}"
		token.text()


	soloExpression: (token) ->
		type token, T.Token

		switch token.constructor
			when T.Name
				if token.kind() == 'x'
					new E.LocalAccess token.pos(), token.text()
				else
					fail()
			when T.Group
				switch token.kind()
					when '|'
						@fun token.body()
					when '('
						@expression token.body()
					when '→'
						todo()
					when '"'
						@quote token.pos(), token.body()
					else
						fail()

			when T.Use
				name =
					token.localName()
				use =
					new E.Use token.pos(), token.path()

				new E.Assign token.pos(), name, null, use

			else
				if token instanceof T.Literal
					new E.JS token.pos(), token.toJS()
				else
					@unexpected token

	quote: (pos, parts) ->
		type pos, Pos
		typeEach parts, T.Token

		new E.Quote pos, parts.map (part) =>
			@soloExpression part

	unexpected: (token) ->
		cFail token.pos(), "Unexpected #{token}"


module.exports = parse = (tokens) ->
	type tokens, Array
	(new Parser).block tokens

