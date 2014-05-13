{ cCheck, cFail, } = require '../compile-help/check'
{ groupMatch } = require '../compile-help/language'
{ check, type } = require '../help/check'
{ isEmpty, last, rightTail } = require '../help/list'
T = require '../Token'
GroupPre = require './GroupPre'

###
Squishes matching `GroupPre`s into `Group`s.
###
module.exports = joinGroups = (tokens) ->
	stack = [ ]
	current = [ ] # Tokens to form this body
	opens = [ ] # GroupPres

	newLevel = (open) ->
		type open, GroupPre
		opens.push open
		stack.push current
		current = [ ]

	finishLevel = ->
		if (T.keyword '\n') last current
			current = rightTail current

		result =
			new T.Group open.pos(), open.kind(), current
		current = stack.pop()
		current.push result

	openKinds =
		[ '(', '→', '|', '@|' ]
	blockCloseKinds =
		[ '←' ]
	closeKinds =
		[ ')' ].concat blockCloseKinds

	for token in tokens
		if token instanceof GroupPre
			pos = token.pos()
			kind = token.kind()
			if kind in openKinds
				newLevel token
			else if kind in closeKinds
				cCheck (not isEmpty opens), pos, ->
					"Unexpected closing #{kind}"
				open = opens.pop()
				cCheck groupMatch[open.kind()] == kind, pos, ->
					"#{open} does not match #{token}"

				finishLevel()

				if kind == '←'
					if (last opens)?.kind() in [ '|', '@|' ]
						open = opens.pop()
						finishLevel()

			else
				fail()

		else
			if token instanceof T.Group # This happens if it's a quote
				token =
					new T.Group token.pos(), token.kind(), joinGroups token.body()
			current.push token


	unless isEmpty opens
		cFail (last opens).pos(), "Never closed #{(last opens).kind()}"
	check isEmpty stack

	current
