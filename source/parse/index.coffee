{ typeEach } = require '../help/check'
E = require '../Expression'
T = require '../Token'
ParseContext = require './ParseContext'

parser = { }
(require './block') parser
(require './case') parser
(require './expression') parser
(require './other') parser
(require './vars') parser

###
Parses the whole file.
###
parseAll = (tokens) ->
	typeEach tokens, T.Token

	context =
		new ParseContext tokens[0].pos()
	new E.BlockWrap context.pos(), parser.block context, tokens

###
Finds the `Expression` that the `tokens` represent.
@param tokens [Array<Token>]
@return [Expression]
###
module.exports = parse = (tokens) ->
	typeEach tokens, T.Token

	parseAll tokens
