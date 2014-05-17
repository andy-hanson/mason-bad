{ cFail } = require '../compile-help/check'
Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
Expression = require './Expression'
TypedVariable = require './TypedVariable'

module.exports = class VarDeclare extends Expression
	constructor: (@_pos, @_vars) ->
		type @_pos, Pos
		typeEach @_vars, TypedVariable

	compile: (context) ->
		decs =
			@_vars.map (aVar) ->
				aVar.var().name()

		[ 'let ', (interleave decs, ', ') ]

	returnable: ->
		no

	returner: ->
		cFail @pos(), 'Block can not end in var declaration.'