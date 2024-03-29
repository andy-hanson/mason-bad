{ cCheck } = require '../compile-help/check'
{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Assignable = require './Assignable'

###
Accesses a local variable.
Does not check if it was ever defined.
Permits global access as well.
###
module.exports = class Local extends Assignable
	###
	@_param _pos [Pos]
	@_param _name [String]
	###
	constructor: (@_pos, @_name) ->
		type @_pos, Pos, @_name, String
		cCheck @_name != 'this', @_pos,
			'Local may not be named `this`. Use `@` instead.'

	# @noDoc
	name: -> @_name

	# @noDoc
	compile: ->
		mangle @name()

	# @noDoc
	assignableCode: (context, isMutate, kind) ->
		if isMutate
			mangle @name()
		else
			[ 'const ', mangle @name() ]

	###
	Local for the result of blocks.
	###
	@res: (pos) ->
		new Local pos, 'res'