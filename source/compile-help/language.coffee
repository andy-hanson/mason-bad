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
		# If it's not used for anything else, it's a valid name!
		/[^\s\(\)\[\]\{\};,'"`\\\|@:.]/


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

@keywords = [
	'use',
	'for',
	'=',
	'. ',
	'|',
	'\n'
]
