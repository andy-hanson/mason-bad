Stream = require './Stream'
tokenize = require './tokenize'
joinGroups = require './joinGroups'

module.exports = lex = (str) ->
	stream =
		new Stream str
	preTokens =
		tokenize stream

	joinGroups preTokens
