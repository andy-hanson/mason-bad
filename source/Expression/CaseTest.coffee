Pos = require '../compile-help/Pos'
{ type } = require '../help/check'
Expression = require './Expression'
typeTest = require './typeTest'

###
A test for use in a Case expression.
In the expression:

	case a
		= 0
			"zero"
		:String
			"string"
		< a 42
			"still not enough"

We see a CaseTest.Equal, CaseTest.Type, and CaseTest.Boolean, in order.
###
module.exports = class CaseTest extends Expression
	###
	Generate the test.
	`cased` will be passed in by the `Case` I am a part of.
	###
	toTest: (context, cased) ->
		@nodeWrap (@toTestPre context, cased), context

	###
	@param pos [Pos]
	@param value [Expression]
	@return [BooleanTest]
	###
	@Boolean: (pos, value) ->
		new BooleanTest pos, value

	###
	@param pos [Pos]
	@param value [Expression]
	  Value to test for equality with.
	@return [EqualTest]
	###
	@Equal: (pos, value) ->
		new EqualTest pos, value

	###
	@param pos [Pos]
	@param type [String]
	@return [TypeTest]
	###
	@Type: (pos, type) ->
		new TypeTest pos, type


###
An arbitrary predicate getting called.
###
class BooleanTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, Expression

	# @noDoc
	toTestPre: (context, cased) ->
		@_value.toNode context

###
Test for exact equality.
###
class EqualTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, Expression

	# @noDoc
	toTestPre: (context, cased) ->
		[ (cased.toNode context), ' === ', @_value.toNode context ]

###
Test for being an instance of a type.
###
class TypeTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_type) ->
		type @_pos, Pos, @_type, String

	# @noDoc
	toTestPre: (context, cased) ->
		typeTest cased.name(), @_type
