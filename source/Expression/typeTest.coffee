{ mangle } = require '../compile-help/JavaScript-syntax'
{ type } = require '../help/check'

# Types that are best checked using the `typeof` operator.
typeOfTypes =
	[ 'Boolean', 'Number', 'String' ]

###
Generates a type test for a given variable name and type name.
###
module.exports = typeTest = (varName, typeName) ->
	type varName, String, typeName, String

	if typeName in typeOfTypes
		[ 'typeof ', varName, ' === "', typeName.toLowerCase(), '"' ]
	else
		[  varName, ' instanceof ', (mangle typeName) ]
