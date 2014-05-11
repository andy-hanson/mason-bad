lex = require './lex'
{ compile } = require './index'
Options = require './Options'

str = '''

factorial = |a
	case a
		= -1
			-1
		< a 2
			1
		else
			* a factorial (- a 1)


'''

type = 'output'

switch type
	when 'tokens'
		for token in lex str
			console.log token.toString()

	when 'output'
		out = compile str
		console.log out.code
