{ cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ isEmpty, last, splitWhere, tail, trySplitOnceWhere, unCons } = require '../help/list'
E = require '../Expression'
T = require '../Token'
ParseContext = require './ParseContext'

module.exports = (parse) ->
	###
	Parses the contents of a block.
	The caller must determine whether it will be in a BlockWrap or Fun.
	@return [Block]
	###
	parse.block = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		lines =
			(splitWhere tokens, T.keyword '\n').filter (line) ->
				not isEmpty line

		{ inLines, outLines, restLines } =
			parseBlockExtra context, lines

		{ lineExprs, allKeys, isList } =
			parseBlockBody context, restLines

		body =
			if isList
				cCheck (isEmpty allKeys), context.pos(),
					'Block contains both list and dict elements.'

				E.BlockBody.List context.pos(), lineExprs
			else if isEmpty allKeys
				E.BlockBody.Plain context.pos(), lineExprs
			else
				E.BlockBody.Dict context.pos(), lineExprs, allKeys

		new E.Block context.pos(), body, inLines, outLines


	###
	@param lines [Array<Array<Token>>]
	@return
	  inLines: Array<Expression>
	  outLines: Array<Expression>
	  rest:Array<Array<Token>>
	###
	parseBlockExtra = (context, lines) ->
		type context, ParseContext
		typeEach lines, Array

		inLines = [ ]
		outLines = [ ]

		# Must be in order: `doc`, `in`, `out`

		if (T.keyword 'in') lines[0]?[0]
			inLines = parseSubBlock context, lines[0]
			lines = tail lines

		if (T.keyword 'out') lines[0]?[0]
			outLines = parseSubBlock context, lines[0]
			lines = tail lines

		inLines: inLines
		outLines: outLines
		restLines: lines


	###
	@return [Array<Expression>]
	###
	parseSubBlock = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		[ opener, rest ] =
			unCons tokens
		[ before, blockTokens ] =
			parse.takeIndentedFromEnd context, rest
		cCheck (isEmpty before), opener.pos(), ->
			"Expected indented block after #{opener}"

		lines =
			(splitWhere blockTokens, T.keyword '\n').filter (line) ->
				not isEmpty line

		{ lineExprs, allKeys, isList } =
			parseBlockBody context, lines

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
	parseBlockBody = (context, lines) ->
		type context, ParseContext
		typeEach lines, Array

		lineExprs = []
		allKeys = []
		isList = no

		lines.forEach (line) =>
			if (T.name '.x') line[0]
				# It's a call on the previous line

				if (isEmpty lineExprs) or not (last lineExprs).returnable()
					unexpected line[0]
				else
					prev =
						lineExprs.pop()
					method =
						new E.Member line[0].pos(), prev, line[0].text()

					lineExprs.push new E.Call method, @expressionParts tail line

			else
				{ content, newKeys } =
					parseLine context, line
				lineExprs.push content
				isList ||= content instanceof E.ListElement
				allKeys.push newKeys...

		lineExprs: lineExprs
		allKeys: allKeys
		isList: isList

	###
	Parses a single line within a block.
	May be an assignment or pure expression.
	Returned `newKeys` are keys to add to this block's object.
	@return [{ content:Expression, newKeys:Array<String> }]
	###
	parseLine = (context, tokens) ->
		type context, ParseContext
		typeEach tokens, T.Token

		t0 = tokens[0]

		isAssign = (x) ->
			((T.keyword '=') x) or ((T.keyword '.') x) or (T.keyword ':=') x

		if t0 instanceof T.Use
			content: parse.use context, tokens
			newKeys: [ ]

		else if (T.keyword 'case!') t0
			content: parse.case context, (tail tokens), no
			newKeys: [ ]

		else if (T.keyword 'loop!') t0
			[ b4, inLoop ] =
				parse.takeIndentedFromEnd context, tail tokens
			cCheck (isEmpty b4), context.pos(), 'Did not expect anything after `loop`'
			content: new E.Loop context.pos(), (parse.block context, inLoop)
			newKeys: [ ]

		else if (T.keyword 'break!') t0
			cCheck (isEmpty tail tokens), context.pos(), 'Did not expect anything after `break!`'
			content: new E.Break context.pos()
			newKeys: [ ]

		else if (T.keyword 'var') t0
			declared =
				parse.typedVariables context, tail tokens

			content: new E.VarDeclare context.pos(), declared
			newKeys: [ ]

		else if (T.keyword '.') t0
			content: new E.ListElement context.pos(), parse.expression context, tail tokens
			newKeys: [ ]

		else if (splitted = trySplitOnceWhere tokens, isAssign)?
			[ nameTokens, assigner, valueTokens ] =
				splitted
			context =
				context.withPos assigner.pos()
			isDictAssign =
				assigner.kind() == '.'
			isMutateAssign =
				assigner.kind() == ':='
			{ vars, names, anyRenames } =
				# Don't allow members if it's a dict assignment.
				parse.maybeRenamedVariables context, nameTokens, isDictAssign
			value =
				parse.expression context, valueTokens

			cCheck vars.length > 0, context.pos(),
				'Assign to nothing'

			content:
				if vars.length > 1 or anyRenames
					new E.AssignDestructure context.pos(), names, value, isMutateAssign
				else
					new E.AssignSingle context.pos(), vars[0], value, isMutateAssign

			newKeys:
				if isDictAssign
					vars.map (_var) ->
						_var.var().name()
				else
					[]

		else
			content: parse.expression context, tokens
			newKeys: []
