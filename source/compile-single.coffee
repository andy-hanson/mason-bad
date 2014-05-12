{ annotateErrors, type } = require './help/check'
E = require './Expression'
lex = require './lex'
Options = require './Options'
parse = require './parse'

module.exports = (source, options) ->
	type source, String, options, Options

	annotateErrors ->
		tokens =
			lex source, options
		expression =
			parse tokens

		node =
			expression.toNode new E.Context.start options
		node.prepend """
		// Compiled from #{options.fileName()}
		//# sourceMappingURL=#{options.shortOutFileName()}.map
		"use strict";
		module.exports = #{}
		"""
		node.add '\n'

		node.toStringWithSourceMap
			file: options.fileName()
	, ->
		"In file #{options.fileName()}"

