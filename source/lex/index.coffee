Stream = require './Stream'
tokenize = require './tokenize'

module.exports = lex = (str) ->
	stream = new Stream str

	tokenize stream
