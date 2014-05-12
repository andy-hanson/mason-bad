rgx = (require 'xregexp').XRegExp
{ type } = require '../help/check'

# <developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Reserved_Words>
javaScriptKeywords =
	"""
	abstract
	arguments
	boolean
	break
	byte
	case
	catch
	char
	class
	comment
	const
	continue
	debugger
	default
	delete
	do
	double
	else
	enum
	eval
	export
	extends
	false
	final
	finally
	float
	for
	function
	goto
	if
	implements
	import
	in
	instanceOf
	int
	interface
	label
	long
	native
	new
	package
	private
	protected
	public
	return
	short
	static
	super
	switch
	synchronized
	this
	throw
	throws
	transient
	true
	try
	typeof
	var
	void
	while
	with
	""".split '\n'

illegalJavaScriptNameChar =
	rgx /[^a-zA-Z0-9_]/g

###
False if `name` will pass as a regular JavaScript variable name.
@param name [String]
@return [Boolean]
###
@needsMangle = (name) ->
	type name, String

	(name in javaScriptKeywords) or Array.prototype.some.call name, (ch) ->
		illegalJavaScriptNameChar.xtest ch

###
Generates a valid JavaScript local name from a Mason one.
These names use `_` as an escape character.
@return [String]_
###
@mangle = (name) ->
	type name, String

	if name in javaScriptKeywords
		"_#{name}"
	else
		name.replace illegalJavaScriptNameChar, (ch) ->
			"_#{ch.charCodeAt 0}"

###
A literal which, if quoted in JavaScript, would represent `str`.
@return [String]
###
@toStringLiteral = (str) ->
	type str, String

	escaped =
		str.replace /["\t\n]/g, (char) ->
			switch char
				when '\n'
					'\\n'
				when '\t'
					'\\t'
				when '"'
					'\\"'

	"\"#{escaped}\""
