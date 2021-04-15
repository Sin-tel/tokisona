# tokisona reference
tokisona is a programming language for toki pona.

## intro
_this guide is in english for now, ideally this would also be in toki pona_

programs are written in (mostly) correct toki pona sentences. `.tps` is used as the file extension for tokisona programs.
* lowercase words should be from the word list.
* capitalised words can be any name that is phonologically correct.
* the only place where you are allowed to break these rules is in comments and strings literals.
* sentences end with `.` or `!`. (stylistically, prefer to use `!` after imperatives or interjections.)
* questions (ie that return some output) end with `?`. some special sentences end with `:`
* commas are ignored. add them if you like. whitespace (tabs etc) is ignored.
`ale` and `ali` are synonymous.
newlines: only allowed (but not required) after a sentence.

## variables
named variables start with capital letter, and a word preceding it to indicate the type.
all variables are global. they dont need to be declared before using them.

variable names are one word and must start with a capital letter and can have additional capital letters in them.
their names must follow toki pona phonotactics: 
	* syllables have a (C)V(N) structure. the consonant is required in all syllables except the first.
	* letters b, c, d, f, g, h, q, r, v, y and z aren't allowed
	* ji, wu, wo, ti are not allowed
	* two nasals (m, n) cannot follow eachother

### number type: `nanpa`
	the numbers are:

	0    | ala
	1    | wan 
	2    | tu 
	3    | wan tu
	4    | tu tu
	5    | luka
	20   | mute
	100+ | ali

by putting them next to eachother you add them.

	78: mute mute mute luka luka luka tu wan

numbers higher than 100 are not allowed. (ali really means infinite)
negative numbers will just produce zero.

### boolean type: `sona` ("fact")
	true  | lon
	false | lon ala

### string type: `nimi` ("words")
can hold any valid tp word or combination of words seperated by spaces
a single word is a valid string. multiple words should be wrapped in "".


## assignment

	Po = 1
	 | nanpa Po li wan.

	Ta = "hello"
	 | nimi Ta li toki.

	So = true
	 | sona So li lon.

	x = evaluate(sentence)
	 | x li ni: [sentence]

## typecasting
changing how you call a variable automatically typecasts it.

* number to string: produces a string like `"mute mute luka wan"`.
* string to number: badly tries to infer the number of objects in the sentence. see 'nanpa akesi.tps'.
* number to boolean: `ala` = `lon ala`, every other number = `lon`
* boolean to number: `lon ala` = `ala`, `lon` = `wan`
* boolean to string: `"lon"`, `"lon ala"`
* string to boolean: strings containing an even amount of "ala" will produce "lon"
	* strings containing an odd amount will produce "lon ala".
	* "toki" => `lon`
	* "akesi ala" => `lon ala`
	* "lon ala ala" => `lon`

	
## questions
	print(x)
	 | nanpa x li seme?
	 | nimi x li seme?
	 | sona x li lon ala lon?

e.g.:

	nanpa Po li seme?
	> wan

## strings
a single word will be interpreted as a string (even keywords).
for multiple words, wrap them in ""

	A = "toki":
	 | nimi A li toki.
these are equivalent:

	nimi Pe li "toki pona li pona.".
	nimi Pe li ni: "toki pona li pona."

## arithmetic
 * add
	| `nanpa x li suli e nanpa y.`
 * subtract
	| `nanpa x li lili e nanpa y.`

e.g.:

	nanpa Po li ni: tu wan li suli e tu.
	nanpa Po li seme?
	> luka

adding strings concatenates them, with a space.

	nimi Toki li toki.
	nimi Pona li pona.
	nimi Toki li suli e nimi Pona. 

prints "toki pona"

there's no multiplication, division, etc.

## logic
not x
	| x ala

	so far, there is no equivalent for 'and', 'or'

## relational operators
only for nanpa:
larger than
`nanpa A la nanpa Pe li suli.`
less than
`nanpa A la nanpa Pe li lili.`
	
! note that these are reversed
`nanpa A la nanpa Pe li suli.`
"considering number A, number B is larger"
=> B > A

for all types:
equal 
`nimi A li sama e nimi Pe.`
not equal
`nimi A li sama ala e nimi Pe.`
these all evaultuate to a boolean (sona)

## control flow
a control block starts eith `e ni:` and is closed with `o pini!`

	[control] e ni:
		[sentence.]
		[sentence.]
	o pini!

break a loop with `o weka!`. doing this in the middle of a program just quits the program. 

## if/else
	
if x then: `x la o pali e ni:`

if statements close with `pini.`

else: `ante la:`


example:

	mute la o pali e ni:
		nanpa A li seme?
		nanpa A li ni: nanpa A li suli e wan.
	ante la, o pali e ni:
	  ante li seme?
	o pini!

## loops
	
while true do:

	tenpo ali la o pali e ni:

repeat x times: 

	tenpo x la o pali e ni:

n.b.:  
the 'tenpo ali' loop will not loop forever.
it stops when the computer gets tired, which is after around 100 iterations or so.
however, you can easily get longer loops by nesting them.

## comments
you can add a comment like this:

	mi pilin e ni: [comment]

multiple lines:

	mi pilin e ni: 
		[comment1]
		[comment2]
	o pini!

## errors 
currently errors arent well reported.
ideally they should be in proper TP.

## examples 
toki.tp

	ma o toki.tp
		"ma o, toki!" li seme?

nanpa pi jan Piponasi.tp

	mi pilin e ni:    
		this program calculates the fibonacci numbers
	o pini!

	"nanpa pi jan Piponasi:" li seme?

	nanpa A li ala.
	nanpa Pe li wan.
	nanpa Se li ala.

	tenpo ali la o pali e ni:
		nanpa A li seme?
		nanpa Se li ni: nanpa A li suli e nanpa Pe.
		nanpa A li nanpa Pe.
		nanpa Pe li nanpa Se.
	o pini!

## ideas
### lists / dictionaries
not implemented.

maybe: 
lipu/poki

ijo pi [index] lon lipu [Name]
Se[1] = 2 | ijo pi nanpa wan lon lipu Se li tu.

### functions/subroutines?
not implemented.