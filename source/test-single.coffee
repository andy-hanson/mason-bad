lex = require './lex'
{ compile } = require './index'
Options = require './Options'

prelude = ''

str = '''
case x
	else
		3
'''

command =
	'output'

options =
	fileName: 'sample-in'
	outFileName: 'sample-out'
	prelude: prelude
	checks:
		types: no
		in: no
		out: no

switch command
	when 'tokens'
		for token in lex str, new Options options
			console.log token.toString()

	when 'output'
		out = compile str, options
		console.log out.code
