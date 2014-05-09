{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

###
Accesses a local variable.
Does not check if it was ever defined.
Permits global access as well.
###
module.exports = class LocalAccess extends Expression
	###
	@_param _pos [Pos]
	@_param _name [String]
	###
	constructor: (@_pos, @_name) ->
		type @_pos, Pos, @_name, String

	# @noDoc
	compile: ->
		mangle @_name
