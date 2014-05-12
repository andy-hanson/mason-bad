{ cFail, cCheck } = require '../compile-help/check'
{ check, type } = require '../help/check'
{ isEmpty } = require '../help/list'
{ repeated } = require '../help/string'
{ quoteEscape } = require '../compile-help/language'
T = require '../Token'
Stream = require './Stream'
GroupPre = require './GroupPre'

allQuoteTypes =
	[ '"', 'doc' ]

###
Gets the parts of a quote.
@return [Group or []]
  If this is a `"` quote, returns it.
  Else, returns an empty array (which ignores the docstring.)
###
module.exports = lexQuote = (stream, oldIndent, quoteType) ->
	type stream, Stream, oldIndent, Number
	check quoteType in allQuoteTypes

	tokenize =
		require './tokenize'

	read = ''
	out = [ ]
	startPos = stream.pos()

	indented =
		stream.peek() == '\n'

	if quoteType == 'doc'
		cCheck indented, stream.pos(),
			'Docstring must be an indented block.'

	quoteIndent =
		oldIndent + 1

	finish = ->
		switch quoteType
			when 'doc'
				[ ]
			when '"'
				text =
					if indented
						read.trimRight()
					else
						read

				unless text == ''
					out.push new T.StringLiteral stream.pos(), text

				if indented and out[0] instanceof T.StringLiteral
					out[0] = new T.StringLiteral out[0].pos(), out[0].value().trimLeft()

				new T.Group startPos, '"', out
			else
				fail()

	loop
		ch =
			stream.readChar()

		# `ch` should always exist because the file must end in a newline;
		# this closes both single-line and indented quotes.
		check ch?

		if ch == '\\'
			next =
				stream.readChar()

			if quoteEscape.has next
				read += quoteEscape.get next
			else
				cFail stream.pos(), "No need to escape '#{next}'"

		else if ch == '{'
			unless read == ''
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
				# Permit blank, un-indented lines within indented quotes.
				read += '\n'
			else if nowIndent < quoteIndent
				# Undo reading those tabs and that new line.
				stream.stepBack nowIndent + 1
				check stream.peek() == '\n'
				return finish()
			else
				read += '\n' + (repeated '\t', nowIndent - quoteIndent)

		else if ch == '"' and quoteType == '"' and not indented
			return finish()

		else
			read += ch

