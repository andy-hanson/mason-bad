
###
`times` copies of `str` concatenated together.
###
@repeated = (str, times) ->
	([0 ... times].map -> str).join ''

