lex = require './lex'
{ compile } = require './index'
Options = require './Options'

prelude = ''

str = '''
case x
	:A[B]
		3
'''

command =
	'output'

options =
	fileName: 'sample-in'
	outFileName: 'sample-out'
	prelude: prelude

switch command
	when 'tokens'
		for token in lex str, new Options options
			console.log token.toString()

	when 'output'
		out = compile str, options
		console.log out.code
