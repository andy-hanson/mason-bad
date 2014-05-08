StringMap = require '../help/StringMap'


###
Maps escapes to what they represent.
###
@quoteEscape = new StringMap
	't': '\t'
	'n': '\n'
	'{': '{'
	'"': '"'
	'\\': '\\'

###
Character classes used during tokenization.
###
@char =
	digit:
		/[0-9]/
	number:
		/[0-9\.]/
	groupPre:
		/[\(\)]/
	space:
		RegExp ' '
	precedesName:
		/[:@\.]/
	name:
		/[a-zA-Z]/

	#precedesName:
	#	/[_:@'\.]/
	# Not _, space, bracket, punc, quote, \, |, @, :, or dot.
	#name:
	#	/[^_\s\(\[\{\)\]\};,'"`\\\|@\:\.]/
	# Like nameChar but can include dot.
	#used:
	#	/[^\s\(\[\{\)\]\};,'"`\\\|@\:]/



###
Maps group openers to closers.
###
@groupMatch =
	'(': ')'
	'→': '←'

###
@groupKinds =
	[ '(', '→', '"', '|' ]
###

@nameKinds =
	[ 'x', '.x', '@x', ':x' ]

@keywords =
	special:
		[ '=', '. ', '|', '\n' ]
