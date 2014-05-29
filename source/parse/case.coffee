{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, last, splitWhere, tail } = require '../help/list'
E = require '../Expression'
T = require '../Token'
ParseContext = require './ParseContext'

module.exports = (parse) ->
	###
	Parse an entire case statement.
	@return [Case]
	###
	parse.case = (context, tokens, isValue) ->
		type context, ParseContext
		typeEach tokens, T.Token
		type isValue, Boolean

		[ casedTokens, block ] =
			parse.takeIndentedFromEnd context, tokens
		cased =
			parse.expression context, casedTokens
		parts =
			(splitWhere block, T.keyword '\n').map (partTokens) =>
				parseCasePart context, partTokens
		elze =
			if (last parts) instanceof E.Block
				parts.pop()
			else
				null

		parts.forEach (part) ->
			cCheck part instanceof E.CasePart, part.pos(),
				'Can only have `else` at end of case'

		new E.Case context.pos(), cased, parts, elze, isValue

	###
	Parse a single test and resulting block within a case statement.
	@return [CasePart]
	###
	parseCasePart = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		[ testTokens, blockTokens ] =
			parse.takeIndentedFromEnd context, tokens

		block =
			parse.block context, blockTokens

		t0 =
			testTokens[0]

		if (T.keyword 'else') t0
			cCheck testTokens.length == 1, t0.pos(),
				'Nothing may follow #{t0}'
			block
		else
			new E.CasePart (parseCaseTest context, testTokens), block

	###
	Parse the test of a CasePart.
	###
	parseCaseTest = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		parts =
			(splitWhere tokens, T.keyword ',').map (testTokens) =>
				t0 =
					testTokens[0]

				if (T.keyword '=') t0
					E.CaseTest.Equal t0.pos(), parse.expression (context.withPos t0.pos()), tail testTokens
				else
					[ theType, rest ] =
						parse.tryTakeType context, tokens

					if theType?
						cCheck (isEmpty rest), theType.pos(),
							"Did not expect anything after type."
						E.CaseTest.Type theType
					else
						E.CaseTest.Boolean context.pos(), parse.expression context, testTokens

		if parts.length == 1
			parts[0]
		else
			E.CaseTest.Or context.pos(), parts
