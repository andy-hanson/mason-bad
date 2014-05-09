{ annotateErrors, type } = require './help/check'
E = require './Expression'
lex = require './lex'
Options = require './Options'
parse = require './parse'

module.exports = (source, options) ->
	type source, String, options, Options

	annotateErrors ->
		lexed = lex source
		expr = parse lexed

		node = expr.toNode new E.Context options, ''

		node.prepend """
		// Compiled from #{options.fileName()}
		//# sourceMappingURL=#{options.shortOutFileName()}.map
		module.exports = #{}
		"""
		node.add '\n'

		node.toStringWithSourceMap
			file: options.fileName()
	, ->
		"In file #{options.fileName()}"

