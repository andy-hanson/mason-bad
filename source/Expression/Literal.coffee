{ toStringLiteral } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

module.exports = class Literal extends Expression
	constructor: (@_pos, @_kind, @_value) ->
		type @_pos, Pos, @_value, String

	kind: -> @_kind

	compile: ->
		switch @_kind
			when 'number', 'javascript'
				@_value
			when 'string'
				toStringLiteral @_value
