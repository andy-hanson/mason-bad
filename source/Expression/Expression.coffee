{ SourceNode } = require 'source-map'
{ abstract, type } =  require '../help/check'
Pos = require '../compile-help/Pos'
Context = require './Context'

###
Represents the meaning of the source code.
###
module.exports = class Expression
	###
	Wraps compiled code with my source-map info.
	@param chunk [Chunk]
	  Compiled code.
	  Chunk = String | SourceNode | Array<Chunk>.
	@return [SourceNode]
	  Compiled code annotated with my @pos() and fileName().
	###
	nodeWrap: (chunk, context) ->
		type context, Context

		new SourceNode \
			@pos().sourceNodeSafeLine(), \
			@pos().column(), \
			context.options().fileName(), \
			chunk

	###
	Return a SourceNode representing this Expression and my source-map info.
	@return [SourceNode]
	###
	toNode: (context) ->
		type context, Context
		@nodeWrap (@compile context), context

	###
	Produce a Chunk of JavaScript for this Expression.
	@abstract
	@return [Chunk]
	  Chunk = JavaScript code, a SourceNode, or an Array of chunks.
	###
	compile: (context) ->
		abstract()

	###
	Where in the file this Expression appeared.
	###
	pos: ->
		@_pos

	###
	Whether this Expression may appear within another
	and be returned from functions.
	###
	pure: ->
		yes
