{ type, typeEach } = require '../help/check'
Expression = require './Expression'

module.exports = class Fun extends Expression
	constructor: (@_pos, @_argNames, @_body) ->
		typeEach @_argNames, String
		type @_body, Expression


