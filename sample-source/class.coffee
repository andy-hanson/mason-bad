
inspect = (name) -> ->
	props =
		(Object.keys @).map (key) =>
			"#{key}: #{@[key]}"

	"#{name}(#{props.join ', '})"

module.exports = (opts) ->
	name =
		opts.name
	members =
		Object.keys opts.members

	assigns =
		for member, index in members
			"this[\"#{member}\"] = members[\"#{member}\"]"

	body = """
	return function #{name}(members)
	{
		if (this instanceof #{name})
		{
			#{assigns.join ';\n\t\t'};
			Object.freeze(this);
		}
		else
		{
			return new #{name}(members);
		}
	}
	"""

	#console.log body

	ctrCtr = new Function(body)

	ctr = ctrCtr()

	ctr.name = name

	ctr.prototype.toString = ctr.prototype.inspect = inspect name

	out = { }
	out[name] =
		ctr

	members.forEach (member) ->
		out["get-#{member}"] = (x) ->
			x[member]

	out
