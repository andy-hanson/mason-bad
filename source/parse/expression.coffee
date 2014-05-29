{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, tail, unCons } = require '../help/list'
E = require '../Expression'
T = require '../Token'
ParseContext = require './ParseContext'

module.exports = (parse) ->
	###
	Parses a pure expression.
	@return [Expression]
	###
	parse.expression = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		if (T.keyword 'case') tokens[0]
			parse.case (context.withPos tokens[0].pos()), (tail tokens), yes
		else
			parts =
				parse.expressionParts context, tokens

			if isEmpty parts
				E.true context.pos()
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
	parse.expressionParts = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		parts = [ ]

		tokens.forEach (token) =>
			isDotName = (T.name '.x') token
			isSub = (T.group '[') token
			x =
				if isDotName or isSub
					if (popped = parts.pop())?
						if isDotName
							new E.Member token.pos(), popped, token.text()
						else
							newContext =
								context.withPos token.pos()
							E.sub token.pos(), popped, parse.expressionParts newContext, token.body()
					else
						unexpected token
				else
					newContext =
						context.withPos token.pos()
					parseSoloExpression newContext, token

			parts.push x if x?

		parts


	###
	Parses a single token which *should* be a pure expression of its own.
	###
	parseSoloExpression = (context, token) ->
		type context, ParseContext
		type token, T.Token

		switch token.constructor
			when T.Name
				switch token.kind()
					when 'x'
						new E.Local token.pos(), token.text()
					when '@x'
						new E.Member token.pos(), (new E.This token.pos()), token.text()
					else
						unexpected token

			when T.Group
				newContext =
					context.withPos token.pos()
				body = token.body()

				switch token.kind()
					when '|', '@|'
						parse.fun newContext, body, token.kind() == '@|'
					when '('
						parse.expression newContext, body
					when '→'
						new E.BlockWrap newContext.pos(), parse.block newContext, body
					when '"'
						new E.Quote newContext.pos(), body.map (token) ->
							parseSoloExpression (context.withPos token.pos()), token
					else
						fail()

			when T.Keyword
				switch token.kind()
					when '@'
						new E.This token.pos()
					else
						parse.unexpected token

			else
				if token instanceof T.Literal
					new E.Literal token.pos(), token.kind(), token.value()
				else
					parse.unexpected token

