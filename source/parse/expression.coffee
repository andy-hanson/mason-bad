{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, tail, unCons } = require '../help/list'
E = require '../Expression'
T = require '../Token'

module.exports = (parse) ->
	###
	Parses a pure expression.
	@return [Expression]
	###
	parse.expression = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		if (T.keyword 'case') tokens[0]
			parse.case tokens[0].pos(), (tail tokens), yes
		else
			parts =
				parse.expressionParts pos, tokens

			if isEmpty parts
				E.true pos
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
	parse.expressionParts = (pos, tokens) ->
		type pos, Pos
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
							E.sub token.pos(), popped, parse.expressionParts token.pos(), token.body()
					else
						unexpected token
				else
					parseSoloExpression token

			parts.push x if x?

		parts


	###
	Parses a single token which *should* be a pure expression of its own.
	###
	parseSoloExpression = (token) ->
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
				pos = token.pos()
				body = token.body()

				switch token.kind()
					when '|', '@|'
						parse.fun pos, body, token.kind() == '@|'
					when '('
						parse.expression pos, body
					when '→'
						new E.BlockWrap pos, parse.block pos, body
					when '"'
						new E.Quote pos, body.map parseSoloExpression
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

