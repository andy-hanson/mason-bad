rgx = (require 'xregexp').XRegExp
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
		rgx /[0-9]/
	number:
		rgx /[\-0-9,.\/e]/
	groupPre:
		rgx /[\(\)\[\]]/
	space:
		rgx ' '
	precedesName:
		rgx /[:@\.~]/
	name:
		# If it's not used for anything else, it's a valid name!
		rgx /[^\s\(\)\[\]\{\};,'"`\\\|@:.~#$]/

###
Every kind a `Group` can have.
###
@groupKinds =
	[ '(', '[', '→', '"', '|', '@|' ]

###
Maps group openers to closers.
###
@groupMatch =
	'(': ')'
	'[': ']'
	'→': '←'

@nameKinds =
	[ 'x', '.x', '@x', ':x', '~x', '...x' ]

@keywords = [
	'case',
	'case!'
	'else',
	'use',
	'for',
	'in',
	'out',
	'var',
	'loop!',
	'break!',
	'=',
	':='
	'.',
	'|',
	'\n',
	'@',
	','
]
