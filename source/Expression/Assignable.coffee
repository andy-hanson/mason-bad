{ abstract } = require '../help/check'
Expression = require './Expression'

###
Something which can appear on the left side of an assignment.
A local variable or property of an object.
###
module.exports = class Assignable extends Expression
	###
	Name used for reporting type errors.
	###
	name: ->
		abstract()

	###
	JavaScript code that will appear left of the `=` sign.
	@param context [Context]
	@param isMutate [Boolean]
	  True if this assignment should change an existing variable.
	  False if it should create a new one.
	###
	assignableCode: (context, isMutate) ->
		abstract()
