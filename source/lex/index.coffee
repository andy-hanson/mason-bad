Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Options = require '../Options'
Stream = require './Stream'
preJoinedTokens = require './pre-joined-tokens'
joinGroups = require './join-groups'

###
Breaks a string down into tokens.
@param sourceCode [String]
@param options [Options]
@return [Array<Token>]
###
module.exports = lex = (sourceCode, options) ->
	type sourceCode, String, options, Options

	# Make sure it ends in a newline.
	sourceCode += '\n'

	if options.prelude()?
		sourceCode = "#{options.prelude()}\n#{sourceCode}"

	pos =
		if options.prelude()?
			Pos.startWithPrelude options.prelude()
		else
			Pos.start()
	stream =
		new Stream sourceCode, pos
	preTokens =
		preJoinedTokens stream

	joinGroups preTokens
