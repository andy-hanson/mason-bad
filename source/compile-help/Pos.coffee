{ type } = require '../help/check'

###
Represents a source position.
1-indexed, as required by source maps.
Immutable, so safe to store in `Expression`s.
###
module.exports = class Pos
	# A simple line, column pair.
	constructor: (@_line, @_column) ->
		type @_line, Number, @_column, Number
		Object.freeze @

	###
	Avoids line numbers < 1 or source map will fail.
	###
	sourceNodeSafeLine: ->
		Math.max @line(), 1

	###
	Which line of the source file.
	@return [Number]
	###
	line: -> @_line

	###
	Which character of the line.
	@return [Number]
	###
	column: -> @_column

	# @return [Pos] One line down and at column 1.
	plusLine: ->
		new Pos @line() + 1, 1

	# @return [Pos] One column to the right.
	plusColumn: ->
		new Pos @line(), @column() + 1

	# @return [Pos] One line up and at column 1.
	minusLine: ->
		new Pos @line() - 1, 1

	# @return [Pos] One column to the left.
	minusColumn: ->
		new Pos @line(), @column() - 1

	# Shows up in errors.
	toString: ->
		"#{@line()}:#{@column()}"

	# `Pos` representing the start of a file.
	@start: ->
		new Pos 1, 1

	###
	Starting position given `prelude`.
	Corrects for the prelude so that the first non-prelude line will be number 1.
	(Prelude lines will be < 1, but they are maxxed to 1 by `sourceNodeSafeLine`.)
	###
	@startWithPrelude: (prelude) ->
		type prelude, String

		preludeLines = (prelude.split '\n').length
		new Pos 1 - preludeLines, 1
