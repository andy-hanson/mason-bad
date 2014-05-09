###
`times` copies of `str` concatenated together.
@param str [String]
@param times [Number]
###
@repeated = (str, times) ->
	([0 ... times].map -> str).join ''

