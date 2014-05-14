{ cCheck, cFail } = require './compile-help/check'
{ check, type, typeEach } = require './help/check'
{ isEmpty, last, rightUnCons, splitWhere, tail, trySplitOnceWhere, unCons } =
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
	Makes a new Parser at the beginning of the file.
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
	@param lines [Array<Array<Token>>]
	@return
	  inLines: Array<Expression>
	  outLines: Array<Expression>
	  rest:Array<Array<Token>>
	###
	blockExtra: (lines) ->
		inLines = [ ]
		outLines = [ ]

		# Must be in order: `doc`, `in`, `out`

		if (T.keyword 'in') lines[0]?[0]
			inLines = @subBlock lines[0]
			lines = tail lines

		if (T.keyword 'out') lines[0]?[0]
			outLines = @subBlock lines[0]
			lines = tail lines

		inLines: inLines
		outLines: outLines
		restLines: lines

	###
	@return [Array<Expression>]
	###
	subBlock: (tokens) ->
		[ opener, rest ] =
			unCons tokens
		[ before, blockTokens ] =
			@takeIndentedFromEnd rest
		cCheck (isEmpty before), opener.pos(), ->
			"Expected indented block after #{opener}"

		lines =
			(splitWhere blockTokens, T.keyword '\n').filter (line) ->
				not isEmpty line

		{ lineExprs, allKeys, isList } =
			@blockBody lines

		cCheck (isEmpty allKeys), opener.pos(),
			'Sub-blocks do not return values and should not have dict entries.'
		cCheck (not isList), opener.pos(),
			'Sub-blocks do not return values and should not have list elements.'

		lineExprs

	###
	@param lines [Array<Array<Token>>]
	@return
	  lineExprs: Array<Expression>
	  allKeys: Array<String>
	  isList: Boolean
	###
	blockBody: (lines) ->
		lineExprs = []
		allKeys = []
		isList = no

		lines.forEach (line) =>
			if (T.name '.x') line[0]
				# It's a call on the previous line
				if (isEmpty lineExprs) or not (last lineExprs).pure()
					@unexpected line[0]
				else
					prev = lineExprs.pop()
					method = new E.Member line[0].pos(), prev, line[0].text()
					lineExprs.push new E.Call method, @expressionParts tail line

			else
				{ content, newKeys } = @line line
				lineExprs.push content
				isList ||= content instanceof E.ListElement
				allKeys.push newKeys...

		lineExprs: lineExprs
		allKeys: allKeys
		isList: isList

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

		{ inLines, outLines, restLines } =
			@blockExtra lines

		{ lineExprs, allKeys, isList } =
			@blockBody restLines

		body =
			if isList
				cCheck (isEmpty allKeys), @_pos,
					'Block contains both list and dict elements.'

				E.BlockBody.List @_pos, lineExprs
			else if isEmpty allKeys
				E.BlockBody.Plain @_pos, lineExprs
			else
				E.BlockBody.Dict @_pos, lineExprs, allKeys

		new E.Block @_pos, body, inLines, outLines

	###
	Parse an entire case statement.
	@return [Case]
	###
	case: (tokens) ->
		typeEach tokens, T.Token

		casePos =
			@_pos

		[ casedTokens, block ] =
			@takeIndentedFromEnd tokens
		cased =
			@expression casedTokens
		parts =
			(splitWhere block, T.keyword '\n').map (partTokens) =>
				@casePart partTokens
		elze =
			if (last parts) instanceof E.Block
				parts.pop()
			else
				null

		parts.forEach (part) ->
			cCheck part instanceof E.CasePart, part.pos(),
				'Can only have `else` at end of case'

		new E.Case casePos, cased, parts, elze

	###
	Parse a single test and resulting block within a case statement.
	@return [CasePart]
	###
	casePart: (tokens) ->
		typeEach tokens, T.Token

		[ testTokens, blockTokens ] =
			@takeIndentedFromEnd tokens

		block =
			@block blockTokens

		t0 =
			testTokens[0]

		if (T.keyword 'else') t0
			cCheck testTokens.length == 1, t0.pos(),
				'Nothing may follow #{t0}'
			block
		else
			new E.CasePart (@caseTest testTokens), block

	###
	Parse the test of a CasePart.
	###
	caseTest: (tokens) ->
		typeEach tokens, T.Token

		parts =
			(splitWhere tokens, T.keyword ',').map (testTokens) =>
				t0 =
					testTokens[0]

				if (T.keyword '=') t0
					E.CaseTest.Equal t0.pos(), @expression (tail testTokens)
				else
					[ theType, rest ] =
						@tryTakeType tokens

					if theType?
						cCheck (isEmpty rest), theType.pos(),
							"Did not expect anything after type."
						E.CaseTest.Type theType
					else
						E.CaseTest.Boolean @_pos, @expression testTokens

		if parts.length == 1
			parts[0]
		else
			E.CaseTest.Or @_pos, parts

	###
	Parses a pure expression.
	@return [Expression]
	###
	expression: (tokens) ->
		typeEach tokens, T.Token

		if (T.keyword 'case') tokens[0]
			@_pos = tokens[0].pos()
			@case tail tokens
		else
			parts =
				@expressionParts tokens

			if isEmpty parts
				E.true @_pos
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
			isDotName = (T.name '.x') token
			isSub = (T.group '[') token
			x =
				if isDotName or isSub
					if (popped = parts.pop())?
						if isDotName
							new E.Member token.pos(), popped, token.text()
						else
							E.sub token.pos(), popped, @expressionParts token.body()
					else
						@unexpected token
				else
					@soloExpression token

			parts.push x if x?

		parts

	###
	Parse a function header and body.
	(The body is parsed by Parser.block().)
	###
	fun: (tokens, preserveThis) ->
		[ argTokens, block ] =
			@takeIndentedFromEnd tokens
		parsedBlock =
			@block block
		t0 =
			argTokens[0]
		[ returnType, tokensAfterReturnType ] =
			if ((T.name ':x') t0) and t0.text() == 'Void'
				[ (E.Type.Void t0.pos()), tail argTokens ]
			else
				@tryTakeType argTokens, yes
		args =
			@typedVariables tokensAfterReturnType

		new E.Fun @_pos, returnType, args, parsedBlock, preserveThis

	###
	Parses a single line within a block.
	May be an assignment or pure expression.
	Returned `newKeys` are keys to add to this block's object.
	@return [{ content:Expression, newKeys:Array<String> }]
	###
	line: (tokens) ->
		unless isEmpty tokens
			@_pos = tokens[0].pos()

		isAssign = (x) ->
			((T.keyword '=') x) or ((T.keyword '.') x) or (T.keyword ':=') x

		if tokens[0] instanceof T.Use
			content: @use tokens
			newKeys: [ ]

		else if (T.keyword '.') tokens[0]
			content: new E.ListElement tokens[0].pos(), @expression tail tokens
			newKeys: [ ]

		else if (splitted = trySplitOnceWhere tokens, isAssign)?
			[ nameTokens, assigner, valueTokens ] =
				splitted
			@_pos =
				assigner.pos()
			isDictAssign =
				assigner.kind() == '.'
			isMutateAssign =
				assigner.kind() == ':='
			{ vars, names, anyRenames } =
				@maybeRenamedVariables nameTokens
			#vars =
			#	# Don't allow members if it's an object assignment.
			#	# So `a.b = 3` is allowed, but not `a.b. 3`.
			#	@typedVariables nameTokens, not isObjectAssign
			value =
				@expression valueTokens

			cCheck vars.length > 0, @_pos,
				'Assign to nothing'

			content:
				if vars.length > 1 or anyRenames
					new E.AssignDestructure @_pos, names, value, isMutateAssign
				else
					new E.AssignSingle @_pos, vars[0], value, isMutateAssign

			newKeys:
				if isDictAssign
					vars.map (_var) ->
						_var.var().name()
				else
					[]

		else
			content: @expression tokens
			newKeys: []

	###
	Read in a local variable from a `Name`.
	@return [Local or JS]
	###
	local: (token) ->
		if token instanceof T.JSLiteral
			new E.JS token.pos(), token.toJS()
		else
			cCheck ((T.name 'x') token), token.pos(), ->
				"Expected plain name, got #{token}"
			new E.Local token.pos(), token.text()

	###
	Parses a single token which *should* be a pure expression of its own.
	###
	soloExpression: (token) ->
		type token, T.Token

		switch token.constructor
			when T.Name
				switch token.kind()
					when 'x'
						new E.Local token.pos(), token.text()
					when '@x'
						new E.Member token.pos(), (new E.This token.pos()), token.text()
					else
						@unexpected token

			when T.Group
				@_pos = token.pos()
				body = token.body()

				switch token.kind()
					when '|', '@|'
						@fun body, token.kind() == '@|'
					when '('
						@expression body
					when '→'
						new E.BlockWrap @_pos, @block body
					when '"'
						new E.Quote @_pos, body.map (part) =>
							@soloExpression part
					else
						fail()

			when T.Keyword
				switch token.kind()
					when '@'
						new E.This token.pos()
					else
						@unexpected token

			else
				if token instanceof T.Literal
					new E.JS token.pos(), token.toJS()
				else
					@unexpected token

	###
	`tokens` *should* end in an indented block.
	@return [ Array<Token>, Array<Token> ]
	  All but the last token, and the body of the indented block.
	###
	takeIndentedFromEnd: (tokens) ->
		typeEach tokens, T.Token

		if isEmpty tokens
			[ tokens, [ ] ]

		else
			[ before, block ] =
				rightUnCons tokens
			cCheck ((T.group '→') block), @_pos, ->
				"Expected to end in block, not #{block}"

			[ before, block.body() ]

	###
	@return [ Type?, Array<Token> ]
	###
	tryTakeType: (tokens, isReturnType) ->
		t0 =
			tokens[0]

		if (T.name ':x') t0
			local =
				new E.Local t0.pos(), t0.text()
			t1 =
				tokens[1]

			if (T.group '[') t1
				@_pos =
					t1.pos()
				subbed =
					@expressionParts t1.body()
				sub =
					E.sub @_pos, local, subbed
				tipe =
					E.Type.Expression sub
				[ tipe, tokens.slice 2 ]
			else
				tipe =
					E.Type.Expression local
				[ tipe, tail tokens ]

		else
			[ null, tokens ]

	###
	@return [Array<TypedVariable>]
	###
	typedVariables: (tokens) ->
		{ vars, _, anyRenames } =
			@maybeRenamedVariables tokens

		cCheck (not anyRenames), @_pos,
			'Did not expect rename'

		vars

	maybeRenamedVariables: (tokens) ->
		vars = []
		names = { }
		anyRenames = no

		until isEmpty tokens
			local =
				@local tokens[0]
			tokens = tail tokens

			dots = []
			while (T.name '.x') tokens[0]
				dots.push tokens[0]
				tokens = tail tokens

			_var = local
			dots.forEach (dot) ->
				_var = new E.Member dot.pos(), _var, dot.text()

			[ varType, tokens ] =
				@tryTakeType tokens

			typedVar =
				E.TypedVariable.fromMaybeType _var, varType

			vars.push typedVar

			[ rename, tokens ] =
				@tryTakeRename tokens

			if rename?
				anyRenames = yes
				names[rename] =typedVar
			else
				names[_var.name()] = typedVar

		vars: vars
		names: names
		anyRenames: anyRenames


	tryTakeRename: (tokens) ->
		if ((T.name '~x') tokens[0])
			[ tokens[0].text(), tail tokens ]
		else
			[ null, tokens ]

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
		isMutate =
			# `use` can never be used to mutate a variable.
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
				@maybeRenamedVariables whatFor

			new E.AssignDestructure use.pos(), names, used, isMutate


###
Finds the `Expression` that the `tokens` represent.
@param tokens [Array<Token>]
@return [Expression]
###
module.exports = parse = (tokens) ->
	type tokens, Array
	(new Parser).all tokens
