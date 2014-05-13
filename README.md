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



Editing Code
---

There is a Sublime Text syntax definition available.
Just run `editor/install-sublime-language.py`.
This will write to `~/.config/sublime-text-3/Packages/User`.


Dicts
---
The core of mason is the dict definition.

	my-dict.
		one. 1
		two. 2

This defines a new dictionary `my-dict` and assigns values to it.
So `my-dict.one` will be `1` and `my-dict.two` will be `2`.
Assignments are done within an indented block of code.

Dict keys can also reference each other.

	my-dict.
		one. 1
		two. + one one

Be sure to leave a space after the `.`!
Otherwise `two.+ one one` would be calling the method `+` on a nonexistent object `two`!



Comments
---

	\ Single-line comment

	\\\
	Multi
	line
	comment
	\\\



Names
---

Any string of non-special characters is a name.
Special characters are:

* Whitespace
* Brackets: `( ) [ ] { }`
* In use: ``" ` \ | @ : . ~ ,``
* Reserved: `# $ ; '`

Also, names can't be numbers, meaning they can't start with a digit or a minus sign followed by a digit.



Lists
---

Everyone loves lists!

	my-list.
		. 1
		. 2
		. 3

Yes, list entries can be the results of blocks.

	my-complex-list.
		.
			x. 1
			y. 2
		.
			. 3
			. 4
		.
			x = 5
			x



Locals
---

Dict assignments (using `. `) make local variables.
If you want to make a local variable but not assign it to a dict, use `=`.


	my-dict.
		one. 1
		two = 2

`my-dict.one` will still be `1` but `my-dict.two` will be undefined.


If a block isn't a dict or list, its value is that of its last line.

	my-number.
		local = 1
		+ local local

In this case, `my-number` will be `2`.
`local` is local to the indented block started by `my-number.`

If you don't provide a value, it will be `null` by default.

	this-is-null.



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

The compiler handles these types specially using `typeof`:

* Bool: Matches booleans.
* Nat, Int, Real: Match numbers. Currently, Nat and Int will match any Real.
* Str: Mathes strings.

All other types are handled using `instanceof`.

You can also describe your types in more detail using `[]`. Everything in the brackets is ignored.

	passes-all-tests. |x:Int tests:Array[Fun[Int -> Bool]]
		...



Conditions
---

You can add code at the beginning and end of functions to check that everything is OK.

	half. |:Int a:Int
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
			= 0
				"none"
			< _ 2
				"some"
			else
				"lots"

To test equality, use `=`.

To do any other test, just write your expression on the line. `_` stands for the value you `case` on.

Use `else` for a fallback. If you don't provide it and none of the tests match, an error will be thrown.

You can also `case` on types:

	what-is-it. |a
		case a
			:String
				"It's a string"
			:Number
				"It's not 42"
			else
				"Who cares?"

If you want to handle many cases the same way, use `,`:

	length. |a
		case a
			:String, :Array, has-property? _ "length"
				a.length
			:Number
				abs a



Use
---

Here's a sample directory structure:

	node_modules/
		burger/
			...
	source/
		court-house.js
		detectives/
			drake.coffee
			you-are-here.mason
		secretaries/
			della.mason

Say you're writing `you-are-here.mason`.

To use a built-in module or one in `node_modules`:

	use fs
	use burger

This is the equivalent of:

	fs = require "fs"
	burger = require "burger"

To use a module from the same directory:

	use .drake
	\ drake = require "./drake"

To use a module in a directory above:

	use ..court-house
	\ court-house = require "../court-house"

Finally:

	use ..secretaries.della
	\ della = require "../secretaries/della"

You can also rename modules:

	use .drake as mop
	\ mop = require './drake'

But usually you'll want to immediately get the module's properties anyway. Remember multiple assignment?

	use ..secretaries.della for dictating investigating
	\ dictating investigating = require "../secretaries/della"



Make Modules
---

The value of a module is the result of running the code.
You shouldn't write to `module.exports` explicitly.



@
---

`@` means `this`, and `@property` means `this.property`.

Normally `this` is not preserved when entering an inner function. E.g.:

	\ Prints 'undefined' three times.
	@prop = 3
	times @prop |
		log! @prop

You can preserve `this` by using `@|`.

	\ Prints '3' three times.
	@prop = 3
	times @prop @|
		log! @prop



JavaScript
---

Sometimes you just gotta shove some JavaScript in there.

	i = 2
	\ Prints 'true'. Post-increment and weakly typed equality. Joy!
	log! `i++ == "2"`

You could also set up your build system to compile both Mason and JavaScript (or CoffeeScript) files together.



Strings
---

Interpolate values into a string using `{}`:

	"I'm pretty sure {+ 1 1} is two."

Multiline quotes can be written in an indented block:

	"
		We hold these truths to be self-evident,
		that {+ 1 1} is two.
		You can use "quote symbols" in block quotes.

You can use `\` for certain special characters:

Escape | Output
:-: | :-:
`\t` | Tab
`\n` | New line
`\{` | `{`
`\\` | `\`



Numbers
---

You can do some funky stuff with number literals.

	1
	1_234_567 \ Underscores are ignored
	1/2 \ Fractions
	1e6 \ Scientific notation



The End
---

What, you wanted more? Too bad! That's really all there is.
If you want more functionality, use modules.

A small standard library is in development.



Building It Yourself
---

	npm install
	grunt
	grunt run-sample --stack
