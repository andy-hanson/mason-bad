T = require '../Token'
Stream = require './Stream'
GroupPre = require './GroupPre'
lexQuote = require './lexQuote'
{ cFail, cCheck } = require '../compile-help/check'
{ char } = require '../compile-help/language'
{ type } = require '../help/check'
{ isEmpty, last, repeat } = require '../help/list'

###
BLAH BLAH
###
module.exports = tokenize = (stream, inQuoteInterpolation = no) ->
	type stream, Stream, inQuoteInterpolation, Boolean

	removePrecedingNewLine = ->
		if (T.special '\n') last out
			out.pop()

	# returns String
	takeName = ->
		cCheck not (char.digit.test stream.peek()), stream.pos(),
			'Expected name, got number'
		name = stream.takeWhile char.name
		cCheck not (isEmpty name), stream.pos(),
			'Expected name, got nothing'
		name


	out = []
	indent = 0

	while ch = stream.peek()
		pos = stream.pos()

		if inQuoteInterpolation and ch == '}'
			stream.skip()
			return out

		match = (regex) ->
			regex.test ch
		maybeTake = (regex) ->
			stream.maybeTake regex

		token =
			switch
				when (match char.digit) or (ch == '-' and char.digit.test stream.peek 1)
					first = stream.readChar()
					num = stream.takeWhile char.number
					new T.NumberLiteral pos, "#{first}#{num}"

				when maybeTake char.groupPre
					new GroupPre stream.pos(), ch

				when ch == '.' and (stream.peek 1) == ' '
					stream.skip 2
					new T.Special pos, '. '

				when ch == '='
					stream.skip()
					new T.Special pos, '='

				when maybeTake char.precedesName
					kind = "#{ch}x"
					name = takeName()
					new T.Name pos, name, kind


				when match char.name
					name = takeName()
					new T.Name pos, name, 'x'

				when maybeTake /\|/
					removePrecedingNewLine()
					new GroupPre pos, ch

				when ch == ' '
					stream.takeWhile char.space
					[ ]

				when ch == '\\'
					stream.takeUpTo /\n/
					[ ]

				when ch == '\n'
					cCheck stream.prev() != ' ', pos, 'Line ends in a space.'

					# Skip blank lines.
					stream.takeWhile /\n/
					old = indent
					now = (stream.takeWhile /\t/).length
					cCheck stream.peek() != ' ', stream.pos(), 'Line begins in a space.'
					indent = now
					if now == old
						removePrecedingNewLine()
						new T.Special pos, '\n'
					else if now < old
						removePrecedingNewLine()
						x = repeat (old - now), new GroupPre stream.pos(), '←'
						x.push new T.Special stream.pos(), '\n'
						x
					else if now == old + 1
						new GroupPre stream.pos(), '→'
					else
						cFail stream.pos(), 'Line is indented more than once.'

				when maybeTake /"/
					lexQuote stream, indent

				when maybeTake /"/

				else
					cFail pos, "Unrecognized character '#{ch}'"

		if token instanceof Array
			out.push token...
		else
			out.push token

	removePrecedingNewLine()

	out

