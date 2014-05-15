{ cCheck, cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
{ tail } = require '../help/string'

###
@param str [String]
@param pos [Pos]
@return [Number]
###
module.exports = lexNumber = (str, pos) ->
	type str, String, pos, Pos

	plainLex = (subStr) ->
		numStr =
			subStr.replace ',', ''
		num =
			Number numStr
		cCheck (not Number.isNaN num), pos,
			"Not a valid number: `#{str}`"
		num.toString()

	parts =
		str.split '/'

	switch parts.length
		when 1
			plainLex parts[0]
		when 2
			console.log '!'
			console.log plainLex parts[0]
			console.log plainLex parts[1]
			console.log str
			console.log parts
			console.log plainLex '2'
			(plainLex parts[0]) / (plainLex parts[1])
		else
			cFail pos, 'Too many `/` in number literal'

