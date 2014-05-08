T = require '../Token'

###
Represents a grouping token (parentheses or indentation)
before the group is formed.
See `joinGroups`.
###
module.exports = class GroupPre extends T.Token
	###
	@param kind [String]
	  A key in `../compile-help/language`.groupMatch.
	###
	constructor: (@_pos, @_kind) ->
		null

	pos: -> @_pos
	kind: -> @_kind

	# @noDoc
	show: ->
		@_kind

