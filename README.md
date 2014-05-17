Mason
---

	mason. language
		types.
			. "declarative"
			. "functional"
		status.
			"nowhere near ready"
		compile-to.
			"JavaScript (`node --harmony`)"



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

You can type local variables (including dict entries), function arguments, and function return values.

	one:Int. 1
	two:Int = 2
	string->array. |:Array str:String
		str.split ""

These compile to method calls on the type. Our first example might be written as:

	one. 1
	Int.!subsumes 1

The method `!subsumes` defaults to calling the predicate method `subsumes?` and throwing an error if it fails.
It may also show more information about why the check failed.

Even if you don't include a type, everything is still checked to not be `undefined` or `null`.
The type `:Void` is treated specially be the compiler and suppresses a function from returning a value.

	say-hi!. |:Void
		log! "Hi"

The type `?` (available in the standard library) allows variables to possibly not be defined.



Subscripts
---

`a[b]` is short for `a.sub b`.
You can subscript types, for example `ints:Array[Int]`.



Conditions
---

Using `in` and `out` you can make assertions before and after a function body.

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

With `case` you can branch based on the value of a variable.

	count-string. |a
		case a
			= 7
				"Lucky number seven."
			:Number
				"Exactly {_}."
			not (truthy? _)
				"Bupkis!"
			:String, :Array
				count-string _.length
			else
				"lots"

To test equality, use `=`.

For a type test, just write the type. (This calls `subsumes?`, not `!subsumes`.)

To do any other test, just write your expression on the line. `_` is the value you `case` on.

To handle many cases the same way, use `,`:

If you don't provide `else` and no test matches, it throws an error.

If you don't want it to return a value, use `case!` instead.



Multiple assignment
---

If you write `a b = dict`, `a` will be `dict.a` and `b` will be `dict.b`.

You can rename these: in `a~eh b~bee = dict`, `a` will be `dict.eh` and `b` will be `dict.bee`.

This works with dict key assignment as well, e.g. `a b. dict`.



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

A module is treated as a single expression.
The value of that expression will be written to `module.exports`.



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



Var
---

You can declare and alter imperative variables. `var` creates a new one, and subsequent alterations use `:=`.
If you use `=` instead the compiler should complain (but this isn't implemented yet).

	var a := 0
	a := 1 \ Changed my mind!



Loop!
---

Sometimes you get the itch to use an imperative loop. `loop!` and `break!` to the rescue!

	\ Counts down from 10 to 1.
	var n := 10
	loop!
		case! n
			positive? _
				log! n
				n := decrement n
			else
				break!



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
