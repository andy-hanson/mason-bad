{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, last, splitWhere, tail } = require '../help/list'
E = require '../Expression'
T = require '../Token'

module.exports = (parse) ->
	###
	Parse an entire case statement.
	@return [Case]
	###
	parse.case = (pos, tokens, isValue) ->
		type pos, Pos
		typeEach tokens, T.Token
		type isValue, Boolean

		[ casedTokens, block ] =
			parse.takeIndentedFromEnd pos, tokens
		cased =
			parse.expression pos, casedTokens
		parts =
			(splitWhere block, T.keyword '\n').map (partTokens) =>
				parseCasePart pos, partTokens
		elze =
			if (last parts) instanceof E.Block
				parts.pop()
			else
				null

		parts.forEach (part) ->
			cCheck part instanceof E.CasePart, part.pos(),
				'Can only have `else` at end of case'

		new E.Case pos, cased, parts, elze, isValue

	###
	Parse a single test and resulting block within a case statement.
	@return [CasePart]
	###
	parseCasePart = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		[ testTokens, blockTokens ] =
			parse.takeIndentedFromEnd pos, tokens

		block =
			parse.block pos, blockTokens

		t0 =
			testTokens[0]

		if (T.keyword 'else') t0
			cCheck testTokens.length == 1, t0.pos(),
				'Nothing may follow #{t0}'
			block
		else
			new E.CasePart (parseCaseTest pos, testTokens), block

	###
	Parse the test of a CasePart.
	###
	parseCaseTest = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		parts =
			(splitWhere tokens, T.keyword ',').map (testTokens) =>
				t0 =
					testTokens[0]

				if (T.keyword '=') t0
					E.CaseTest.Equal t0.pos(), parse.expression t0.pos(),(tail testTokens)
				else
					[ theType, rest ] =
						parse.tryTakeType pos, tokens

					if theType?
						cCheck (isEmpty rest), theType.pos(),
							"Did not expect anything after type."
						E.CaseTest.Type theType
					else
						E.CaseTest.Boolean pos, parse.expression pos, testTokens

		if parts.length == 1
			parts[0]
		else
			E.CaseTest.Or pos, parts
