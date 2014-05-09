Stream = require './Stream'
tokenize = require './tokenize'
joinGroups = require './joinGroups'

###
Breaks a string down into tokens.
@return [Array<Token>]
###
module.exports = lex = (str) ->
	# Make sure it ends in a newline.
	str += '\n'

	stream =
		new Stream str
	preTokens =
		tokenize stream

	joinGroups preTokens
