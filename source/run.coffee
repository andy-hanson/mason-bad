
lex = require './lex'

tokens = lex 'one two three'

for token in tokens
	console.log token


