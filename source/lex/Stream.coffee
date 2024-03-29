rgx = (require 'xregexp').XRegExp
Pos = require '../compile-help/Pos'
{ cCheck } = require '../compile-help/check'
{ check, type } = require '../help/check'
{ times } = require '../help/other'

###
Pretends that a string is streaming.
###
module.exports = class Stream
	###
	@param str [String]
	  Full text (this is not a real stream).
	###
	constructor: (@_text, @_pos) ->
		type @_text, String, @_pos, Pos
		@_index = 0

	###
	If the next character is in `charClass`, read it.
	###
	maybeTake: (charClass) ->
		type charClass, RegExp
		charClass = rgx charClass

		@readChar() if charClass.xtest @peek()

	###
	The next (or skip-th next) character without modifying the stream.
	###
	peek: (skip = 0) ->
		@_text[@_index + skip]

	###
	Current position in the file.
	###
	pos: ->
		@_pos

	###
	The character before `peek()`.
	###
	prev: ->
		@peek -1

	###
	Takes the next character (modifying the stream).
	###
	readChar: ->
		x = @peek()
		if x == '\n'
			@_pos = @_pos.plusLine()
		else
			@_pos = @_pos.plusColumn()
		@_index += 1
		x


	###
	Goes forward `n` characters.
	@param n [Number]
	###
	skip: (n = 1) ->
		times n, =>
			@readChar()

	###
	Goes back `n` characters.
	(If it goes back a line, column info is destroyed,
		but that's OK since \n doesn't become an Expression.)
	###
	stepBack: (n = 1) ->
		times n, =>
			@_index -= 1
			if @peek() == '\n'
				@_pos = @_pos.minusLine()
			else
				@_pos = @_pos.minusColumn()


	###
	Reads as long as characters satisfy `condition`.
	@param condition [Function, RegExp]
	@return [String]
	###
	takeWhile: (condition) ->
		if condition instanceof RegExp
			charClass = rgx condition
			condition = (char) ->
				charClass.xtest char
		else
			type condition, Function

		start =
			@_index

		while @peek() and condition @peek()
			@readChar()

		@_text.slice start, @_index

	###
	Reads until a character is in `charClass`.
	Does not read that character.
	###
	takeUpTo: (charClass) ->
		type charClass, RegExp
		charClass = rgx charClass

		@takeWhile (char) ->
			not charClass.xtest char

	###
	Reads until a character is in `charClass`.
	Skips over that character, but does not return it in the result.
	###
	###
	takeUpToAndIncluding: (charClass) ->
		type charClass, RegExp
		charClass = rgx charClass

		start = @_index

		while ch = @peek()
			@readChar()
			if charClass.xtest ch
				break

		@_text.slice start, @_index - 1
	###

	###
	@return [Boolean]
	  Whether `N` of charClass were ever found.
	###
	takeUntilNOf: (charClass, N) ->
		type charClass, RegExp, N, Number
		charClass = rgx charClass

		n = 0

		while yes
			x = @readChar()
			unless x?
				return no

			if charClass.xtest x
				n += 1
				if n == N
					return yes
			else
				n = 0

