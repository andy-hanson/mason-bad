{ cCheck, cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ check, type, typeEach } = require '../help/check'
{ isEmpty, last, rightUnCons } = require '../help/list'
E = require '../Expression'
T = require '../Token'
ParseContext = require './ParseContext'

module.exports = (parse) ->
	###
	Parse a function header and body.
	(The body is parsed by Parser.block().)
	###
	parse.fun = (context, tokens, preserveThis) ->
		type context, ParseContext
		typeEach tokens, T.Token
		type preserveThis, Boolean

		[ argTokens, blockTokens ] =
			if (T.group '→') last tokens
				parse.takeIndentedFromEnd context, tokens
			else
				[ tokens, [ ] ]
		body =
			parse.block context, blockTokens
		t0 =
			argTokens[0]
		[ returnType, tokensAfterReturnType ] =
			if ((T.name ':x') t0) and t0.text() == 'Void'
				[ (E.Type.Void t0.pos()), tail argTokens ]
			else
				parse.tryTakeType context, argTokens, yes
		args =
			parse.typedVariables context, tokensAfterReturnType

		new E.Fun context.pos(), returnType, args, body, preserveThis

	###
	`tokens` *should* end in an indented block.
	@return [ Array<Token>, Array<Token> ]
	  All but the last token, and the body of the indented block.
	###
	parse.takeIndentedFromEnd = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		if isEmpty tokens
			[ tokens, [ ] ]

		else
			[ before, block ] =
				rightUnCons tokens
			cCheck ((T.group '→') block), context.pos(), ->
				"Expected to end in block, not #{block}"

			[ before, block.body() ]

	###
	Throws a compiler error when a bad token is encountered.
	###
	parse.unexpected = (token) ->
		type token, T.Token
		cFail token.pos(), "Unexpected #{token}"

	###
	Parses a `use` line.
	@return [AssignSingle | AssignDestructure]
	###
	parse.use = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		use = tokens[0]
		check use instanceof T.Use

		used =
			new E.Require use.pos(), use.path()
		isMutate =
			# `use` can never be used to mutate a variable.
			no
		isDictAssign =
			# `use` never assigns to a dict.
			no

		moduleLocal =
			new E.Local use.pos(), use.localName()
		_var =
			E.TypedVariable.defaultTyped moduleLocal

		if tokens.length == 1
			new E.AssignSingle use.pos(), _var, used, isMutate
		else
			[ _, _for, whatFor... ] = tokens
			cCheck ((T.keyword 'for') _for), _for.pos(), ->
				"Expected 'for', got #{_for}"

			{ _, names, _ } =
				parse.maybeRenamedVariables context, whatFor, isDictAssign

			new E.AssignDestructure use.pos(), names, used, isMutate
