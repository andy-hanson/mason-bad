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

	###
	What kind of group this will be.
	A member of `groupMap` from `../compile-help/language`, or `'"'`.
	###
	kind: -> @_kind

	# @noDoc
	show: -> @_kind

