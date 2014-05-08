{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class LocalAccess extends Expression
	constructor: (@_pos, @_name) ->
		type @_pos, Pos, @_name, String

	compile: ->
		mangle @_name
