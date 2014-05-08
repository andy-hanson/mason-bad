E = require './Expression'
lex = require './lex'
parse = require './parse'

###
@return [{ code, map }]
###
module.exports = compileSingle = (string, options) ->
	lexed = lex string
	expr = parse lexed
	node = expr.toNode new E.Context options, ''

	node.prepend """
	// Compiled from #{options.fileName()}
	//# sourceMappingURL=#{options.shortOutFileName()}.map
	module.exports = function()

	"""
	node.add '()\n'

	node.toStringWithSourceMap
		file: options.fileName()


