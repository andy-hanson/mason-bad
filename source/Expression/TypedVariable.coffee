{ mangle } = require '../compile-help/JavaScript-syntax'
Pos = require '../compile-help/Pos'
{ check, type, typeExist } = require '../help/check'
Assignable = require './Assignable'
Expression = require './Expression'
Type = require './Type'

###
A variable and maybe a type.
###
module.exports = class TypedVariable extends Expression
	###
	@param _var [Assignable]
	@param _type [Expression?]
	###
	constructor: (@_var, @_type) ->
		type @_var, Assignable
		typeExist @_type, Type

	# @noDoc
	pos: -> @var().pos()

	###
	The variable being assigned to.
	@return [Assignable]
	###
	var: -> @_var

	###
	Whether a type was specified.
	@return [Boolean]
	###
	hasType: ->
		@_type?

	###
	Generate code to assert that the variable is an instance of the given type.
	###
	typeCheck: (context) ->
		check @hasType()
		@_type.toCheck context, @_var, @_var.name()
