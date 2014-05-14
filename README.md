mason
---

	mason. language
		types.
			. "declarative"
			. "functional"
		status.
			"nowhere near ready"
		compile-to.
			"JavaScript"



Getting Started
---

Someday there will be an easy way to get started.



Dicts
---
The core of mason is the dict definition.

	my-dict.
		one. 1
		two. + one one

This defines a new dictionary `my-dict` and assigns values to it.
So `my-dict.one` will be `1` and `my-dict.two` will be `2`.
Each `key. value` assignment is done within an indented block of code.
*Be sure to leave a space after the `.`*, or you are accessing a property!

Dict keys are also local variables and can reference each other.
If a key has no written value, it will be `True` by default.

	this-is-true.



Lists
---

Lists are also written in indented blocks.
Each line beginning with `. ` (remember the spaec!) writes a new entry to the list.
List entries can theirselves be blocks.

	my-list.
		. 1
		two = 2
		. two
		.
			x. 1
			y. 2



Locals
---

To create a local that's not a dict assignment, use `=`.

	two.
		one = 1
		+ one one

`one` can not be accessed outside of the indented block.

If a block isn't a dict or list, its value is that of its last line.



Call Functions
---

Haven't we forgot something?

	log! "Hello World!"

Function calls are made simply by juxtaposing a function with its arguments.
No parentheses, no commas.

	two =
		+ 1 1

However, if an argument is itself a function call, you'll have to encase it in parentheses.

	log! (+ 1 1)



Make Functions
---

You can make your own functions too.

	decrement = |a
		- a 1

	\ Prints '0'
	log! (decrement 1)

The `|` opens the function and arguments are written on the same line.
The body of the function must go in an indented block.



Multiple Assignment
---

You can get many properties of a dict at once.

	my-dict.
		a. 1
		b. 2
	a b = my-dict

`a` will be `1` and `b` will be `2`.



Types
---

You can give types to local variables, including dict entries.

	one:Int. 1
	two:Int. "2" \ Fails!

Function arguments can be given types as well.

	decrement = |a:Int
		- a 1

	decrement 1 \ Succeeds!
	decrement "one" \ Fails!

You can specify return types by putting the type right after the `|`.

	decrement = |:Int a:Int
		"I am real legitimate Number"

	decrement 1 \ Fails!

Our first example might be written as:

	one. 1
	Int.!subsumes 1

The method `!subsumes` defaults to calling the predicate method `subsumes?` and throwing an error if it fails. You can write your own custom type with just `subsumes?`, or make a fancy `!subsumes` that gives you a better error message as well.



Subscripts
---

Many types rely on subscripting. `a[b]` is short-hand for `a.sub b`.
`x:Array[Int] = y` would generate a check like `(Array.sub Int).!subsumes x`.



Conditions
---

You can add code at the beginning and end of functions to check that everything is OK.

	half. |a
		in
			assert (divisible? a 2)
		out
			(* res 2).should.equal a

		/ a 2

Here we are using assertions from [Chai](http://chaijs.com), but anything could be used.

Note the special variable `res`; this is created at the end of every function.

(By the way, type checks happen *before* custom checks.)



Case
---

With `case` you can neatly deal with all the potential values of a variable.

	count-string. |a
		case a
			= 7
				"Lucky number seven."
			:Number
				"Exactly {_}."
			not (truthy? _)
				"Bupkis!"
			:String, :Array, has-property? _ "length"
				count-string _.length
			else
				"lots"

To test equality, use `=`.

To test for inclusion in a type, write the type name preceded by `:`. (This calls `subsumes?`, not `!subsumes`.)

To do any other test, just write your expression on the line. `_` is the value you `case` on.

If you want to handle many cases the same way, use `,`:

If you don't provide an `else` case and no test matches, it throws an error.



Multiple assignment
---

If you write `a b = dict`, `a` will be `dict.a` and `b` will be `dict.b`.
You can rename these: in `a~eh b~bee = dict`, `eh` will be `dict.a` and `bee` will be `dict.b`.



Use
---

There is an easier syntax for using `require`.

Use | Require
:-- | :--
`use fs` | `fs = require "fs"`
`use .drake` | `drake = require "./drake"`
`use ..court-house` | `court-house = require "../court-house"`
`use ..secretaries.della` | `della = require ../secretaries/della`
`use graceful-fs~fs` | `fs = require "graceful-fs"`
`use fs for read write` | `read write = fs`


Make Modules
---

The value of a module is the result of running the code.
Don't write to `module.exports` explicitly.



@
---

`@` means `this`, and `@property` means `this.property`.

Normally `this` is lost when entering an inner function.
You can preserve `this` by using `@|`.

	\ Prints '3'.
	@prop = 3
	do @|
		log! @prop



Strings
---

Interpolate values into a string using `{}`:

	"I'm pretty sure {+ 1 1} is two."

Multiline quotes can be written in an indented block:

	"
		We hold these truths to be self-evident,
		that {+ 1 1} is two.
		You can use "quote symbols" in block quotes.

`\` escapes certain special characters:

Escape | Output
:-: | :-:
`\t` | Tab
`\n` | New line
`\{` | `{`
`\\` | `\`



Numbers
---

You can do some funky (and *experimental*) stuff with number literals.

	lots. 123,456 \ Commas are ignored
	pi. 22/7 \ Fractions
	us-debt. 18e12 \ Scientific notation



Names
---

Names can contain any non-special characters is a name.
Special characters are:

* Whitespace
* Brackets: `( ) [ ] { }`
* In use: ``" ` \ | @ : . ~ ,``
* Reserved: `# $ ; '`

Also, names can't be numbers or keywords.



Comments
---

	\ Single-line comment

	\\\
	Multi-line
	comment
	\\\

	doc
		Docstring. This should go at the start of a function.



JavaScript
---

Sometimes you just gotta shove some JavaScript in there.

	i = 2
	\ Prints 'true'. Post-increment and weak equality. Joy!
	log! `i++ == "2"`



The End
---

What, you wanted more? Too bad! That's really all there is.
If you want more functionality, use modules.

A small standard library is in development.



Editing Code
---

There is a Sublime Text syntax definition available.
Just run `editor/install-sublime-language.py`.
This will write to `~/.config/sublime-text-3/Packages/User`.


Building It Yourself
---

	npm install
	grunt
	grunt run-sample --stack
