{ cFail, cCheck } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ char, keywords } = require '../compile-help/language'
{ type } = require '../help/check'
{ dropWhile, isEmpty, last, repeat } = require '../help/list'
T = require '../Token'
GroupPre = require './GroupPre'
lexQuote = require './lex-quote'
lexNumber = require './lex-number'
Stream = require './Stream'

###
Gets a `Use` token out of a string.
@return [Use]
###
lexUse = (pos, str) ->
	type pos, Pos, str, String

	parts =
		str.split '.'
	realParts =
		dropWhile parts, (part) ->
			part == ''
	nLevelsUp =
		parts.length - realParts.length

	new T.Use pos, nLevelsUp, realParts


###
Converts a string into tokens, including `GroupPre`s.
###
module.exports = preJoinedTokens = (stream, inQuoteInterpolation = no) ->
	type stream, Stream, inQuoteInterpolation, Boolean

	removePrecedingNewLine = ->
		if (T.keyword '\n') last out
			out.pop()

	# returns String
	takeName = ->
		cCheck not (char.digit.xtest stream.peek()), stream.pos(),
			'Expected name, got number'
		name =
			stream.takeWhile char.name

		cCheck not (isEmpty name), stream.pos(),
			'Expected name, got nothing'

		name


	out = []
	indent = 0

	while ch = stream.peek()
		pos =
			stream.pos()

		if inQuoteInterpolation and ch == '}'
			stream.skip()
			return out

		match = (regex) ->
			regex.xtest ch
		maybeTake = (regex) ->
			stream.maybeTake regex

		token =
			switch
				when (match char.digit) or (ch == '-' and char.digit.xtest stream.peek 1)
					numString =
						stream.takeWhile char.number
					num =
						lexNumber numString, pos

					new T.NumberLiteral pos, num

				when maybeTake char.groupPre
					new GroupPre stream.pos(), ch

				when maybeTake /,/
					new T.Keyword pos, ','

				when ch == '.' and /\s/.test stream.peek 1
					stream.skip 1
					new T.Keyword pos, '.'

				when maybeTake char.precedesName
					kind = "#{ch}x"
					if ch == '@' and maybeTake /\|/
						new GroupPre pos, '@|'
					else if ch == ':' and maybeTake /\=/
						new T.Keyword pos, ':='
					else if ch in [ '.', '@' ] and not char.name.xtest stream.peek()
						new T.Keyword pos, ch
					else
						name = takeName()
						new T.Name pos, name, kind

				when match char.name
					name = takeName()
					if name == 'use'
						stream.takeWhile /[ ]/
						lexUse stream.pos(), (stream.takeUpTo /\s/).trim()
					else if name == 'doc'
						lexQuote stream, indent, 'doc'
					else if name in keywords
						new T.Keyword stream.pos(), name
					else
						new T.Name pos, name, 'x'

				when maybeTake /\|/
					new GroupPre pos, ch

				when ch == ' '
					stream.takeWhile char.space
					[ ]

				when ch == '\\'
					if (stream.peek 1) == '\\' and (stream.peek 2) == '\\'
						stream.skip 3
						stream.takeUntilNOf /\\/, 3
						cCheck stream.peek() == '\n', stream.pos(), ->
							"Block comment must be followed by newline, not '#{stream.peek()}'"
					else
						stream.takeUpTo /\n/
					[ ]

				when ch == '['
					pos = stream.pos()
					stream.readChar()
					n = 1
					while yes
						done =
							switch stream.readChar()
								when '['
									n += 1
									no
								when ']'
									n -= 1
									n == 0
								when '\n', undefined
									cFail pos, 'Unclosed `[`'
								else
									no
						if done
							break
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
						new T.Keyword pos, '\n'
					else if now < old
						removePrecedingNewLine()
						x = repeat (old - now), new GroupPre stream.pos(), '←'
						x.push new T.Keyword stream.pos(), '\n'
						x
					else if now == old + 1
						new GroupPre stream.pos(), '→'
					else
						cFail stream.pos(), 'Line is indented more than once.'

				when maybeTake /"/
					lexQuote stream, indent, '"'

				when maybeTake /`/
					# Javascript literal
					text = stream.takeUpTo /[`\n]/
					switch stream.readChar()
						when '`'
							new T.JSLiteral pos, text
						else
							cFail pos, "Unclosed Javascript literal"

				else
					cFail pos, "Unrecognized character '#{ch}'"

		if token instanceof Array
			out.push token...
		else
			out.push token

	removePrecedingNewLine()

	out

