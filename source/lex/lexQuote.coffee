{ cFail, cCheck } = require '../compile-help/check'
{ check, type } = require '../help/check'
{ isEmpty } = require '../help/list'
{ repeated, withoutStart } = require '../help/string'
{ quoteEscape } = require '../compile-help/language'
T = require '../Token'
Stream = require './Stream'
GroupPre = require './GroupPre'

###
Gets the parts of a quote.
###
module.exports = lexQuote = (stream, oldIndent) ->
	type stream, Stream, oldIndent, Number

	tokenize =
		require './tokenize'

	read = ''
	out = [ ]
	startPos = stream.pos()

	indented =
		stream.peek() == '\n'
	quoteIndent =
		oldIndent + 1

	closeQuote =
		'"'

	finish = ->
		text =
			if indented
				(withoutStart read, '\n').trimRight() # skip initial newline
			else
				read

		out.push new T.StringLiteral stream.pos(), text
		new T.Group startPos, '"', out

	loop
		ch =
			stream.readChar()

		cCheck ch?, startPos, 'Unclosed quote.'

		if ch == '\\'
			next =
				stream.readChar()

			if quoteEscape.has next
				read += quoteEscape.get next
			else
				cFail startPos, "No need to escape '#{next}'"

		else if ch == '{'
			out.push new T.StringLiteral stream.pos(), read
			read = ''
			startPos =
				stream.pos()
			interpolated =
				tokenize stream, yes

			out.push new T.Group startPos, '(', interpolated

		else if ch == '\n'
			cCheck indented, startPos, 'Unclosed quote.'
			# Read an indented section.
			nowIndent =
				(stream.takeWhile /\t/).length

			if nowIndent == 0 and stream.peek() == '\n'
				read += '\n'
			else if nowIndent < quoteIndent
				# Undo reading those tabs and that new line.
				stream.stepBack nowIndent + 1
				check stream.peek() == '\n'
				return finish()
			else
				read += '\n' + (repeated '\t', nowIndent - quoteIndent)

		else if ch == closeQuote and not indented
			return finish()

		else
			read += ch
