Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
{ interleave } = require '../help/list'
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
		= 0, :String, < a 42
			"one of the above"

We see a CaseTest.Equal, CaseTest.Type, and CaseTest.Boolean, in order.
Then we see them all together in a CaseTest.Or.
###
module.exports = class CaseTest extends Expression
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
	@param pos [Pos]
	@param type [String]
	@return [OrTest]
	###
	@Or: (pos, parts) ->
		new OrTest pos, parts

###
An arbitrary predicate getting called.
###
class BooleanTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, Expression

	# @noDoc
	compile: (context) ->
		@_value.toNode context

###
Test for exact equality.
###
class EqualTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_value) ->
		type @_pos, Pos, @_value, Expression

	# @noDoc
	compile: (context) ->
		[ '_ === ', @_value.toNode context ]

###
Test for being an instance of a type.
###
class TypeTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_type) ->
		type @_pos, Pos, @_type, String

	# @noDoc
	compile: (context) ->
		typeTest '_', @_type

class OrTest extends CaseTest
	# @noDoc
	constructor: (@_pos, @_parts) ->
		type @_pos, Pos
		typeEach @_parts, CaseTest

	compile: (context) ->
		interleave (@_parts.map (part) -> part.compile context), ' || '
