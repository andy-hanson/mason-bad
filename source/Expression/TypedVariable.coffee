Pos = require '../compile-help/Pos'
{ check, type, typeExist } = require '../help/check'
Assignable = require './Assignable'
Expression = require './Expression'
typeTest = require './typeTest'

###
A variable and maybe a type.
###
module.exports = class TypedVariable extends Expression
	###
	@param _var [Assignable]
	@param _type [String?]
	###
	constructor: (@_var, @_type) ->
		type @_var, Assignable
		typeExist @_type, String

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

		if @_type?
			name =
				@var().name()
			test =
				typeTest name, @_type
			err =
				[	'throw new Error("\'',
					name, '\' is no ', @_type,
					', it\'s " + ', name, ')' ]
			checkCode =
				[ 'if (!(', test, '))\n', context.indent(), '\t', err ]

			@nodeWrap checkCode, context

		else
			''
