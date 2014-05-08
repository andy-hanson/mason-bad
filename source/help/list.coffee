
@dropWhile = (list, condition) ->
	idx = 0
	while idx < list.length
		unless condition list[idx]
			break
		idx += 1

	list.slice idx

###
A new list with `interleaved` in between every element of `list`.
###
@interleave = (list, interleaved) ->
	out = exports.interleavePlus list, interleaved
	out.pop()
	out

###
Like `interleave` but with another of `interleaved` at the end.
###
@interleavePlus = (list, interleaved) ->
	out = [ ]
	for element in list
		out.push element, interleaved
	out

###
Whether `list` contains no elements.
###
@isEmpty = (list) ->
	list.length == 0

###
The last element in `list`.
###
@last = (list) ->
	list[list.length - 1]

###
A list of `times` `value`s.
###
@repeat = (times, value) ->
	[1..times].map ->
		value

###
Breaks `list` by elements where `condition`.
@return [Array<Array>]
  Arrays where `condition` is false.
  Elements where `condition` is true are discarded.
###
@splitWhere = (list, condition) ->
	if module.exports.isEmpty list
		[ ]
	else
		out = [ ]
		cur = [ ]
		list.forEach (elem) ->
			if condition elem
				out.push cur
				cur = [ ]
			else
				cur.push elem
		out.push cur
		out

###
Every element but the first.
###
@tail = (list) ->
	Array.prototype.slice.call list, 1

###
@return [(Array, Any, Array), null]
	[ first, splitter, rest ] if can split, else null.
###
@trySplitOnceWhere = (list, condition) ->
	for em, index in list
		if condition em
			return [ (list.slice 0, index), em, (list.slice index + 1) ]
	null

###
The first element, and everything else.
@return [(Array, Object)]
###
@unCons = (list) ->
	[ list[0], exports.tail list ]
