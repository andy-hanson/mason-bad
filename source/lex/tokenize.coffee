Stream = require './Stream'
{ type } = require '../help/check'
{ cFail } = require '../compile-help/check'
{ char } = require '../compile-help/language'

###
BLAH BLAH
###
module.exports = tokenize = (stream, inQuoteInterpolation = no) ->
	type stream, Stream, inQuoteInterpolation, Boolean

	out = []

	while ch = stream.peek()
		pos = stream.pos()

		if inQuoteInterpolation and ch == '}'
			stream.readChar()
			return out

		match = (regex) ->
			regex.test ch
		maybeTake = (regex) ->
			stream.maybeTake regex

		token =
			switch
				when maybeTake /./
					3

		if token instanceof Array
			out.push token...
		else
			out.push token

	out

