{ mangle } = require '../compile-help/JavaScript-syntax'
{ type } = require '../help/check'

###
Types that are specially handled using `typeof`.
Maps type names to the expected result of calling `typeof`.
###
typeOfTypes =
	Bool: 'boolean'
	Nat: 'number'
	Int: 'number'
	Real: 'number'
	Str: 'string'

###
Generates a type test for a given variable name and type name.
###
module.exports = typeTest = (varName, typeName) ->
	type varName, String, typeName, String

	if typeOfTypes.hasOwnProperty typeName
		typeOfResult =
			typeOfTypes[typeName]
		[ 'typeof ', (mangle varName), ' === "', typeOfResult, '"' ]
	else
		[  (mangle varName), ' instanceof ', (mangle typeName) ]
