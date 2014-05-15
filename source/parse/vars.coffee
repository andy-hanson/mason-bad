{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, tail } = require '../help/list'
E = require '../Expression'
T = require '../Token'

module.exports = (parse) ->
	###
	Read in a local variable from a `Name`.
	@return [Local or JS]
	###
	parse.local = (token) ->
		type token, T.Token

		if (T.literal 'javascript') token
			new E.JS token.pos(), token.value()

		else
			cCheck ((T.name 'x') token), token.pos(), ->
				"Expected plain name, got #{token}"

			new E.Local token.pos(), token.text()


	parse.maybeRenamedVariables = (pos, tokens, isDictAssign) ->
		type pos, Pos
		typeEach tokens, T.Token
		type isDictAssign, Boolean

		vars = []
		names = { }
		anyRenames = no

		until isEmpty tokens
			local =
				parse.local tokens[0]
			tokens = tail tokens

			_var = local

			if isDictAssign
				if (T.name '.x') tokens[0]
					cFail tokens[0].pos(), 'Members can not be assigned to as dict keys.'
			else
				while (T.name '.x') tokens[0]
					member = tokens[0]
					_var = new E.Member member.pos(), _var, member.text()
					tokens = tail tokens

			[ varType, tokens ] =
				parse.tryTakeType pos, tokens

			typedVar =
				E.TypedVariable.fromMaybeType _var, varType

			vars.push typedVar

			[ rename, tokens ] =
				tryTakeRename pos, tokens

			if rename?
				anyRenames = yes
				names[rename] =typedVar
			else
				names[_var.name()] = typedVar

		vars: vars
		names: names
		anyRenames: anyRenames


	tryTakeRename = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		if ((T.name '~x') tokens[0])
			[ tokens[0].text(), tail tokens ]
		else
			[ null, tokens ]


	###
	@return [Array<TypedVariable>]
	###
	parse.typedVariables = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		{ vars, _, anyRenames } =
			parse.maybeRenamedVariables pos, tokens, no

		cCheck (not anyRenames), pos,
			'Did not expect rename'

		vars

	###
	@param pos [Pos]
	@param tokens [Array<Token>]
	@return [ Type?, Array<Token> ]
	###
	parse.tryTakeType = (pos, tokens) ->
		type pos, Pos
		typeEach tokens, T.Token

		t0 =
			tokens[0]

		if (T.name ':x') t0
			local =
				new E.Local t0.pos(), t0.text()
			t1 =
				tokens[1]

			if (T.group '[') t1
				pos =
					t1.pos()
				subbed =
					parse.expressionParts pos, t1.body()
				sub =
					E.sub pos, local, subbed
				tipe =
					E.Type.Expression sub
				[ tipe, tokens.slice 2 ]

			else
				tipe =
					E.Type.Expression local
				[ tipe, tail tokens ]

		else
			[ null, tokens ]
