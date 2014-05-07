{ check } = require './check'

###
@param action [Function]
	Thing to do.
@param n [Number]
	Number of times to do action.
###
@times = (n, action) ->
	check n >= 0
	[0 ... n].forEach action
