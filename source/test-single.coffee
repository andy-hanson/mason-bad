lex = require './lex'
{ compile } = require './index'
Options = require './Options'

str1 = '''
a = 0
b. 0
one .two @three :four 5 -6.789
'''

str2 = '''
use ..mod
'''

tokens = lex str2

for token in tokens
	console.log token.toString()

out = compile str2

console.log out.code

