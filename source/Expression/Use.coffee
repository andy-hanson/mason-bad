Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Use extends Expression
	constructor: (@_pos, @_path) ->
		type @_pos, Pos, @_path, String

	compile: ->
		[ 'require("', @_path, '")' ]
