Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'

###
Requires a module.
###
module.exports = class Require extends Expression
	###
	@param _pos [Pos]
	@param _path [String]
	  Either a relative path to the module,
	  or the module's name if it is in `node_modules`.
	###
	constructor: (@_pos, @_path) ->
		type @_pos, Pos, @_path, String

	# @noDoc
	compile: ->
		[ 'require("', @_path, '")' ]
