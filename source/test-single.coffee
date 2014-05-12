lex = require './lex'
{ compile } = require './index'
Options = require './Options'

prelude = ''

str = '''
use .class
use .singleton
use .js-util for exists?

Option = class
	name. "Option"

	factory. |x
		case x
			exists? x
				Option.Some
					value. x
			else
				Option.None

	static. |Option
		Some. class
			name. "Some"
			super. Option
			members.
				value.

		None. singleton
			name. "None"
			super. Option

		force. |a:Option message
			case a
				:Some
					_.value
				= None
					`throw new Error((message == null) ? "Tried to force None" : explain)`
					()

Option

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
