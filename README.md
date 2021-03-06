# tokisona
_ilo Tokisona li toki pi ilo sona._

tokisona is a programming language for/in toki pona. programs are written in (mostly) correct toki pona sentences. `.tps` is used as the file extension for tokisona programs. (subject to change, since github thinks this is PLSQL)

see [`reference.md`](reference.md) for a guide on how to use it. [`grammar.txt`](grammar.txt) contains a BNF description of the grammar.

## example
this program produces the fibonacci numbers.

	"nanpa pi jan Piponasi:" li seme?

	nanpa A li ala.
	nanpa Pe li wan.
	nanpa Se li ala.

	tenpo mute la o pali e ni:
		nanpa A li seme?
		nanpa Se li ni: nanpa A li suli e nanpa Pe.
		nanpa A li nanpa Pe.
		nanpa Pe li nanpa Se.
	o pini!

equivalent lua code:

	print("the Fibonacci numbers:")

	a = 0
	b = 1
	c = 0

	for i = 1, 20 do
		print(a)
		c = a + b
		a = b
		b = c
	end

some more examples can be found in the [`lipu`](lipu) folder.

## how does this work?
source code is parsed and compiled into lua code. the lua interpreter does the hard work of actually running it.

 * [`src/lexer.lua`](src/lexer.lua): convert file to list of tokens (words, punctuation).
 * [`src/parser.lua`](src/parser.lua): a recursive descent parser. it generates an abstract syntax tree (AST) from list of tokens.
 * [`src/transpiler.lua`](src/transpiler.lua): traverse the AST and generate lua code.

see [`src/out_fibonacci.lua`](src/out_fibonacci.lua) for an example of the generated code.

## how do i use it?
make sure you have lua installed. [`src/tokisona.lua`](src/tokisona.lua) does all the necessary steps to compile and run code. to execute the file 'toki.tps', run:

	lua tokisona.lua toki.tps

if want to debug programs or see the syntax tree, [`src/main.lua`](src/main.lua) has more info.

## sublime text 3 support
you can download this repo and open it as a sublime project.
theres a bunch of files in the [`sublime`](sublime) folder, copy these to your `Packages/User` folder. (which is usually somewhere like `%appdata%\Sublime Text 3\Packages\User`)

it provides:
* syntax highlighting
* autocomplete
* `ctrl+/` shortcut for commenting lines
* `.tps` extension association
* build file (you may need to set the paths correctly)

![syntax highlighting](syntax_highlight.png)
