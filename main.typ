#import "@preview/touying:0.6.1": *
#import themes.university: *

#import "@preview/pinit:0.2.2": *
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#show: codly-init

#codly(languages: codly-languages)
//#codly(languages: ("PHP Source": (name: "PHP", color: purple, icon: emoji.elephant)))
//#codly(lang-format: ("PHP Source", _, _) => [PHP]))
#codly(display-name: false)
#codly-disable()


#import "@preview/cetz:0.3.4"

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [PHP's Type System Dissected],
    subtitle: [Understanding how PHP's type system works],
    author: [Gina P. Banyard],
    date: "2025-09-19"/*datetime.today()*/,
    institution: [The PHP Foundation],
    //logo: emoji.school,
  ),
  config-colors(
    primary: rgb("#111827"),
    secondary: rgb("#6B57FF"),
    //tertiary: rgb("#448C95"),
    tertiary: rgb("#111827"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#111827"),
  ),
)

#let member-list-element(width: 30%, def, body) = {
  [/ #box(width: width, align(right, def)) : #body]
}

#let warning(body) = {
  block(
    fill: rgb(255, 255, 0, 30%),
    inset: 20pt,
    radius: 4pt,
    width: 100%,
)[
  === Warning
  #body
]
}

#set quote(block: true)
#set raw(lang: "PHP Source")

#title-slide()

== About me
#slide[
  #image("php_foundation.svg")
][
  - BSc in Pure Mathematics from Imperial College London
  - Works on PHP since 2019
  - Funded by *The PHP Foundation* since 2022
  - Cares about type systems
  - Cares about PHP semantics

  / Mastodon: `@Girgias@phpc.social`
  / Website: #link("https://gpb.moe")[`gpb.moe`]
  / GitHub: `Girgias`
]

= PHP’s Type System

== What is a Type System

#quote(attribution: [Wikipidia @noauthor_type_2025])[
  A *type system* is a logical system comprising a set of rules that assigns a property called a _type_ to every "term".

  A type system dictates the operations that can be performed on a term.
]

== Why care about types?

#quote(attribution: <dijkstra_humble_1972>)[
  The purpose of abstracting is *not* to be vague, but to create a new semantic level in which one can be absolutely precise. 
]

== PHP's Type System

- Atomic types
  - Primitive types
  - User defined types
  - Singleton types
  - The `callable` type
- Composite types
- Type aliases

== Atomic types: Primitive types

#member-list-element("Universal Type")[`mixed` (PHP 8.0@kocsis_php_2020)]
#member-list-element("Resource Type")[]
#member-list-element("Object Type")[`object` (PHP 7.2@brzuchalski_php_2016)]
#member-list-element("Hash Table Type")[`array`]
#member-list-element("Scalar Type")[`bool`, `int`, `float`, `string`]
#member-list-element("Unit Type")[`null` (PHP 8.0\*@banyard_php_2022-2)]
#member-list-element("Empty Type")[`never` (PHP 8.1@brown_php_2021)]

And a special return only type:
#member-list-element("")[`void`]

== Atomic types: User defined classes

Also called *class-types*:
#member-list-element("Classes")[_aka_ *product* types]
#member-list-element("Interfaces")[]
#member-list-element("Enumerations")[_aka_ *sum* (/co-product) types (PHP 8.1@tovilo_php_2020)]

*relative-class* types:

#member-list-element()[`self`][]
#member-list-element()[`parent`][]
#member-list-element()[`static`][only as a return type (PHP 8.0@popov_php_2020)]

== Atomic types: Singleton types

A singleton type is a concrete _subtype_ of a type.

#member-list-element()[`false`][(PHP 8.0\*@banyard_php_2022-2)]
#member-list-element()[`true`][(PHP 8.2@banyard_php_2022-1)]

#warning()[
  It’s impossible to define a singleton type in user land.
  Create an enumeration instead.
]

== Atomic types: `callable` type

Represents a function:
- `Closure`
  - anonymous functions
  - obtainable via the `my_function(...)` syntax (PHP 8.1@popov_php_2021)
  - obtainable via `ReflectionFunction::getClosure()`
- A string with the name of the function `"my_function"`
- An object/method name pair: `[$object, "method_name"]`
- Instance of an object that implements `__invoke()`

#warning()[
  It’s impossible to define a class property as `callable`.
]

== Composite types

A composite type is a type combining multiple atomic types.

#member-list-element(width: 55%)[Simple union type (PHP 8.0@popov_php_2019)][`T|S`]
#member-list-element(width: 55%)[Intersection type (PHP 8.1@banyard_php_2021)][`X&Y`]
#member-list-element(width: 55%)[
  DNF#footnote[
    In boolean logic, a _Disjunctive Normal Form_ or _DNF_ is a canonical normal form of
    a logical formula consisting of a disjunction of conjunctions; it can also be
    described as an *OR* of *ANDs*.
  ] types (PHP 8.2@banyard_php_2021-1)
][`(A&B)|(X&Y)`]

== Composite types: visualization

// TODO Add callable closure
#cetz.canvas({
  import cetz.draw: *
  //line((-1.5, 0), (1.5, 0))
  //line((0, -1.5), (0, 1.5))

  rect(align:center, name:"universe", (0,0), (26,12))
  content((rel: (-2, -1)), [`mixed`])
  content((12,-0.5), [`never`])
  
  circle((22.5, 7), radius: 3, fill: rgb(0, 255, 0, 10%))
  content((), [`array`])
  
  rect(align:center, name:"objects", (0.5, 3), (19,11.5))
  content((rel: (-2, -1)), [`object`])

  circle((7, 7), radius: (6, 3.5), name:"Countable", fill: rgb(255, 0, 0, 10%), fill-rule: "even-odd")
  circle((rel: (5, 0)), radius: (6, 3.5), name:"Traversable", fill: rgb(0, 0, 255, 10%))
  content((3.5, 7), [`Countable`])
  content((15.5, 7), [`Traversable`])
  content((10, 7), [`Countable
  &
Traversable`])
  //intersections("CaT", "Countable", "Traversable", fill: "#000000")
  
  circle((21, 2), radius: 1, fill: rgb(255, 255, 0, 10%))
  content((), [`int`])
  circle((24, 2), radius: 1.5, fill: rgb(0, 255, 255, 10%))
  content((), [`float`])

  circle((5,2), radius: 0.1, fill: black)
  content((rel: (1.5,0)), [`null`])

})

// TODO bool type?

== Composite types: why do we care?

*Intersection* of types allows using _every_ API provided by each type

*Union* of types only allows using the _common_ API of all types

== Type aliases

As of PHP 8.2, `iterable` is a compile time alias. @noauthor_convert_nodate

$ #text[`iterable`] := #text[`Traversable`]|#text[`array`] $

Before it was a _pseudo_-type

#warning()[
  It’s impossible to define a type alias in user land.
]


== Internal representation: Values are `zval`s

#codly-enable()

#slide[
  ```c
struct _zval_struct {
  zend_value value;
  uint32_t type_info;
};
  ```
][
  ```c
#define IS_NULL    1
#define IS_FALSE    2
#define IS_TRUE     3
#define IS_LONG     4
#define IS_DOUBLE   5
#define IS_STRING   6
#define IS_ARRAY    7
#define IS_OBJECT   8
#define IS_RESOURCE 9
/* ... */
```
]

== Internal representation: `zend_type`

#slide[
  `ptr` is either a class name
  ```c
typedef struct {
  void *ptr;
  /* Bit-mask of primitive
     types and type info */
  uint32_t type_mask;
} zend_type;
  ```
][
  #pause
  or a list of type
  ```c
typedef struct {
  uint32_t num_types;
  zend_type types[1];
} zend_type_list;
```
]

= Subtyping and LSP

== What is subtyping

#quote(attribution: [Wikipedia @noauthor_subtyping_2024])[
  In programming language theory, *subtyping* is a form of type polymorphism, in which a subtype is a data type that is related to another data type (the supertype) by some notion of substitutability.

    If $S$ is a subtype of $T$, the subtyping relation (written as $S <: T$, $S subset.eq.sq T$, or  $S <=: T$ ) means that any term of type $S$ can *safely* be used in *any* context where a term of type $T$ is expected.
]

== Liskov Substitution Principle

#quote()[
  The Liskov Substitution Principle (*LSP*) is a particular definition of a subtyping relation, called strong behavioural subtyping.
    //\cite{liskov_behavioral_1994}
]
Formulated by Barbara Liskov and Jeannette Wing in 1994:

#quote(attribution: <liskov_behavioral_1994>)[
  Let $phi(x)$ be a property provable about objects $x$ of type *$T$*.
  
  Then $phi(y)$ should be _true_ for objects $y$ of type *$S$* where *$S$* is a *subtype* of *$T$*.
//Cite https://dl.acm.org/doi/10.1145/197320.197383
]
    
== LSP: Visualized

//@lsp-pipe shows a glacier. Glaciers are complex systems.

#figure(
  image("lsp-pipes.png", height: 75%),
  caption: [Visualization of Liskov Substitution Principle as a pipe. @seemann_liskov_2021],
)

== LSP: Simplified

#member-list-element("Pre-conditions")[cannot be strengthened in the subtype]
#member-list-element("Post-conditions")[cannot be weakened in the subtype]
#member-list-element("Invariants")[must be preserved in the subtype]
#member-list-element("History Rule")[constraints must be preserved in the subtype]

== LSP: Effects on signatures

#member-list-element("Methods")[cannot add mandatory parameters]
#member-list-element("Parameter types")[
  of methods must be _contra-variant_, #linebreak()#box(width: 24%) i.e. a supertype
]
#member-list-element("The Return type")[of methods must be _co-variant_, i.e. a subtype]
#member-list-element("Property types")[must be _co_ *and* _contra_-variant]

== Expanding on the History Rule

Subtypes must not alter the state of the supertype in ways that are not possible for the supertype to do.

#pause

#quote(attribution: <stroustrup_use_1997>)[
  Members declared protected are far more open to abuse than members declared private.
  In particular, declaring data members protected is usually a design error.
]

== When is $S subset.eq.sq T$?

Generally $S subset.eq.sq T$ if:
 - $S$ intersects $T$ with a new type $U$ $(T\&U subset.eq.sq T)$
 - $S$ removes a type $T_i$ from a union of types $T := T_1|T_2|...|T_n$ 

// TODO Image to showcase this?

== Examples of $S subset.eq.sq T$: union types

#show: codly-init

```
class Super1 {
    public function foo(): T|S|U|V {}
}

class Sub1 extends Super1 {
    public function foo(): U|V {}
}
```

== Examples of $S subset.eq.sq T$: intersection types

```
class Super2 {
    public function foo(): A&B {}
}

class Sub2 extends Super2 {
    public function foo(): A&B&C&D {}
}
```

== Examples of $S subset.eq.sq T$

```
interface A {}
class X implements A {}
class Y implements A {}

class Super3 {
    public function foo(): A {}
}
class Sub3 extends Super3 {
    public function foo(): X|Y {}
}
```

== Examples of $S subset.eq.sq T$

```
interface A {}
interface B {}
class X implements A, B {}
class Y implements A, B {}

class Super4 {
    public function foo(): A&B {}
}
class Sub4 extends Super4 {
    public function foo(): X|Y {}
}
```

== Examples of $S subset.eq.sq T$

```
interface A {}
interface B {}
class X implements A, B {}
class Y implements A, B {}

class Super5 {
    function foo(): (A&B)|D {}
}
class Sub5 extends Super5 {
    function foo(): X|Y|D {}
}
```

== Examples of $S subset.eq.sq T$

```
interface A {}
interface B {}
interface C {}
interface X extends A {}

class Super6 {
    public function foo(): A|B {}
}
class Sub6 extends Super6 {
    public function foo(): X&C {}
}
```

#focus-slide[#align(center, [_MATH ALERT_])]

== $U subset.eq.sq V$ with $U$ a union type

$forall$ means "For All", $exists$ means "There exists".

Let $U = {U_1, ..., U_n}$ and $V = {V_1, ..., V_m}$ be sets of types.

if $V$ is a union type:
$ U_1 | ... | U_n subset.eq.sq V_1 | ... | V_m & <== forall U_i, pin("union_subtype_1")exists V_j : U_i subset.eq.sq V_j $

if $V$ is an intersection type:
$ U_1 | ... | U_n subset.eq.sq V_1 \& ... \& V_m & <== forall U_i,  pin("union_subtype_2")forall V_j : U_i subset.eq.sq V_j $

Basically: iterate over the types $U_i$ of $U$ and verify $U_i subset.eq.sq V$

#pause

#pinit-double-arrow(start-dx: 8pt, start-dy: 10pt, end-dx: 8pt, end-dy: -20pt, "union_subtype_1", "union_subtype_2")

== Approximation in PHP

```
$u = [$u1, $u2, /* ... */, $uN];
$v = [$v1, $v2, /* ... */, $vM];
$early_status_exit = false;
foreach ($u as $type) {
  if (is_intersection_type($type)) {
    $status = is_intersection_subtype($type, $v);
  } else {
    $status = is_single_type_subtype($type, $v);
  }
  if ($status == $early_exit_status) { return $status; }
}
```

== $U subset.eq.sq V$ with $U$ an intersection type

$forall$ means "For All", $exists$ means "There exists".

Let $U = {U_1, ..., U_n}$ and $V = {V_1, ..., V_m}$ be sets of types.

if $V$ is a union type:
$ U_1 \& ... \& U_n subset.eq.sq V_1 | ... | V_m & <== pin("intersection_subtype_1")exists V_j, exists U_i : U_i subset.eq.sq V_j $

if $V$ is an intersection type:
$ U_1 \& ... \& U_n subset.eq.sq V_1 \& ... \& V_m & <== pin("intersection_subtype_2")forall V_j, exists U_i : U_i subset.eq.sq V_j $


#pause
#only(2)[
#pinit-fletcher-edge(fletcher, "intersection_subtype_1", start-dy:-10pt, start-dx:25pt, (1.5,0), bend: -50deg, "<->")

Order of quantifiers is _flipped_ $=>$ need to iterate on $V$ first.
]
#only(3)[
#pinit-double-arrow(start-dx: 8pt, start-dy: 10pt, end-dx: 8pt, end-dy: -20pt, "intersection_subtype_1", "intersection_subtype_2")
]

== todo

// If $V$ is a union type, it suffices to have one $(i;j)$ pair that satisfies $U_i subset.eq.sq V_j$ for $U subset.eq.sq V$.

// Otherwise, each $V_j$ needs to be satisfied by at least one $U_i$ for $U subset.eq.sq V$.

== Approximation in PHP

```
function is_intersection_subtype($sub, $super) {
  $early_status = !is_intersection_type($super);
  foreach ($super as $single) {
    if (is_intersection_type($single)) {
      $status = is_intersection_subtype($sub, $single);
    } else {
      $status = is_subtype_of_class($sub, $single);
    }
    if ($status == $early_status) { return $status; }
  }
  return !$early_status; }
```

== LSP Reframed in terms of testing

#quote(attribution: <baniassad_reframing_2021>)[
  We explore a new pedagogical framing of the LSP.
  [...]
  we advocate an operationalised version of the rule:
  that a sub-type must pass its supertype’s *black box* tests for each of its overriding methods.

  [...] black box tests should be written to capture conformance to a specification without overfitting or checking implementation internals.
]

= Future of PHP's type system?


== User defined type aliases

#v(10%)

`typedef numeric int|float`

`type numeric as int|float`

== Singleton types

#v(10%)
Allowing the use of `int` and `string` values as singleton types

- `1|2|4`
- `"hello"|"world"`
- `SOME_CONSTANT|ANOTHER_CONSTANT`

== Function types

#v(10%)
Specify signature of `callable`/`Closure` parameters/return values

`foo(fn<int,string>:bool $callable) { /* ... */ }`

For functions that have the following signature:
```
function bar(int $i, string $s): bool {}
```

== Generics

```
class Collection<T> {
    private array<T> $stack = [];
    public function push(T $v) {
        $this->stack[] = $v;
    }
    public function pop(): T {
      return array_pop($this->stack);
    }
}
```

#pause

Generics are hard to make fast at run-time with a good DX. @le_blanc_state_2024

== Abstract Generics

```
interface I<K : string|int, V> {
  public function get(K $offset): V;
  public function set(K $offset, V $value): void;
}
class C implements I<string, User> {
  public function get(string $offset): User {/* ... */}
  public function set(string $offset, User $value): void { /* ... */ }
 }
```

== In-out parameters

Normal PHP references do not enforce a type constraint:
#only(1)[
  #codly(footer: [int(5)])
```
function foo(array &$v) {
  $v = 5;
}
$a = [];
foo($a);
var_dump($a);
```
]
#only(2)[
  #codly(footer: [_TypeError: inout argument 1 passed to foo() must be of
the type array, int assigned on line 2_])
```
function foo(inout array $v) {
  $v = 5;
}
$a = [];
foo($a);
```
]

== Effect types

Communicate what effects a function does
- `function print(string $str): void!output {}`
- `function fopen(string $path): resource!io|warning {}`
- `function div(float $n, float $q):
            float!throw<DivisionByZero> {}`
- `function now(): DateTimeImmutable!time`

== Dependent types

// TODO: Concept of a range type
// TODO: Use string[length: range<1..>] for non empty strings

= PHP's `strict_types`

== Audience question

#pause

Who has _heard_ about `strict_types`?

#pause

Who *knows* what `strict_types` does?

== Type Juggling Contexts in PHP

- String
- Integral and String
- Numeric
- Logical
- Comparative
- Function
- "Special" type juggling contexts
  - Increment/Decrement operators
  - Array offsets
  - String offsets
  - `exit()` prior to PHP 8.4 // TODO Citation?

== String Type Juggling Context

Context used for `echo`, `print`, string interpolation, and `.` operator.

#codly(footer: [string(7) "1 hello"])
```
var_dump(true . " hello");
``` <string-1>
#codly(footer: [
  Warning: Array to string conversion on line 3#linebreak()
  Array are great], offset-from: <string-1>)
```
$a = [1, 2, 3];
echo $a . " are great";
``` <string-2>
#codly(footer: [Fatal error: Uncaught Error: Object of class stdClass could not be converted to string], offset-from: <string-2>)
```
print new stdClass();
``` <string-3>

== Integral and String Type Juggling Context

Context when using bitwise operators (`|`, `&`, `~`, `^`)
#codly(footer: [string(3) "qrs"])
```
var_dump("123" | "abc");
```<int-string-1>

#codly(footer: [int(127)], offset-from: <int-string-1>)
```
var_dump(36 | "123");

``` <int-string-2>
#codly(footer: [object(GMP)#2 (1) { ["num"]=> string(2) "61" })], offset-from: <int-string-2>)
```
var_dump(36 | gmp_init(25));
```

== Numeric Type Juggling Context

Context when using arithmetic operators (`+`, `-`, `*`, `/`, `**`, `%`)

#codly(footer: [int(37)])
```
var_dump(36 + true);
```<arithmetic-1>

#codly(footer: [float(1123)], offset-from: <arithmetic-1>)
```
var_dump("123" + "1e3");
``` <arithmetic-2>

#codly(footer: [object(GMP)#2 (1) { ["num"]=> string(2) "61" })], offset-from: <arithmetic-2>)
```
var_dump(36 + gmp_init(25));
```

== Logical Type Juggling Context

Context when using conditional statements, the ternary operator, or logical operators (`||`, `&&`, `!`, `and`, `or`, `xor`)

#codly(footer: [
PHP 8.4 $>=$:
Hello

PHP 8.4 $<$:
Recoverable fatal error: Object of class GMP could not be
converted to bool on line 2
])
```
$o = gmp_init(10);
if ($o) {
    echo "Hello";
}
```

== Comparative Type Juggling Context

Context when using a comparison operator (`==`, `===`, `!=`, `<`, `<=`, `>`, `>=`, `<=>`)

#table(
  columns: (2fr, 2fr, 7fr),
  inset: 10pt,
  align: (center+horizon, center+horizon, auto),
  table.header(
    [*Type OP1*], [*Type OP2*], [*Result*],
  ),
  [`string|null`], [`string|null`], [Convert `null` to `""`, numerical or lexical comparison],
  [`bool|null`], [`mixed`], [Convert both sides to `bool`: $#raw("false") < #raw("true")$],
  [`object`], [`object`], [Built-in classes can overload comparisons, same classes compare properties, else incomparable],
  [`string|resource|int|float`], [`string|resource|int|float`], [Convert `string` and `resource` to number, usual mathematical comparison],
  [`array`], [`array`], [OP with less elements is smaller, if a key of OP1 does not exist in OP2 $=>$ uncomparable, else compare elements by value.],
  [`object`], [`mixed`], [`object` is always greater],
  [`array`], [`mixed`], [`array` is always greater],
)

== Comparison Rules: Implications

#member-list-element(width: 40%)[`[] <=> true`][$=> \O\P\1 < \O\P\2$]
#member-list-element(width: 40%)[`"1" <=> "01"`][$=> \O\P\1 = \O\P\2$]
#member-list-element(width: 40%)[`"0e5" <=> "0e9"`][$=> \O\P\1 = \O\P\2$]
#member-list-element(width: 40%)[`"hello" <=> "world"`][$=> \O\P\1 < \O\P\2$]

#pause
=== Incomparability

#codly(footer: [
int(1)#linebreak()
int(1)
])
```
$a1 = [15, 20];
$a2 = ["a" => "a", "b" => "b"];
var_dump($a1 <=> $a2);
var_dump($a2 <=> $a1);
```

== Comparison Rules: Weirdness

// TODO Non comutativity + object to int notice

== Function Type Juggling Context

Context for values passed to a typed parameter, property, or returned from a function which declares a return type.#linebreak()
In this context, the value must be a value of the type.#linebreak()
#pause
Exceptions:

- `int` to `float` promotion
- Type and value are scalars, value coerced to type if compatible
- The `string` type accepts objects that are castable to `string`

#warning()[
  Internal functions coerce `null` for scalar type, deprecated in PHP 8.1
  // TODO Citation 
]

== `int` to `float` Promotion

#codly(footer: [
float(15)
])
```
function something_with_float(float $f) {
    var_dump($f);
}

something_with_float(15);
```

== Scalar Types Coercion

If multiple scalars types are allowed, the order is the following:

+ `int`
+ `float`
+ `string`
+ `bool`

== Scalar Types Coercion: `float` to `int|string`

#codly(footer: [
Deprecated: Implicit conversion from float 15.6 to int loses precision on line 5
#linebreak()int(15)
])
```
function thing_with_int_or_string(int|string $v) {
    var_dump($v);
}

thing_with_int_or_string(15.6);
```

== Scalar Types Coercion: `string` to `int|float`

#codly(footer: [
float(15.6)#linebreak()
int(25)
])
```
function thing_with_int_or_float(int|float $v) {
  var_dump($v);
}

thing_with_int_or_float("15.6");
thing_with_int_or_float("25");
```

== Special Type Juggling Contexts

  - Array offsets
    - Throw `Error` for `array` and `object` offsets
    - `null` cast to an empty string `""`
    - `resource`, `bool`, `float` cast to `int`
    - Integer `string`s cast to `int` (e.g. `"7"` but *not* `"007"`)
  - String offsets
    - Non-`int` values emit an `E_WARNING` or throw an `Error`
  - `exit()` prior to PHP 8.4
    - `int` used as status code, everything else cast to `string`
  - Increment/Decrement operators
    - Wooooooo booooooiiii

== Special Type Juggling Contexts: `++`/`--`

Behaves like `$v += 1` or `$v -= 1` for:
- `int`
- `float`
- Internal objects that overload `+`/`-`

`TypeError` for:
- `array`
- `resource`
- `object`

== `++`/`--` and `null`

#only(1)[
PHP $<= 8.2$
#codly(footer: [
NULL
#linebreak()
int(1)
])
```
$n = null;
var_dump(--$n);
$n = null;
var_dump(++$n);
```
]
#only(2)[
PHP $>= 8.3$
#codly(footer: [
Warning: Decrement on type null has no effect,
this will change in the next major version of PHP
on line 2
#linebreak()
NULL
#linebreak()
int(1)
])
```
$n = null;
var_dump(--$n);
$n = null;
var_dump(++$n);
```
]

== `++`/`--` with `false`

#only(1)[
PHP $<= 8.2$
#codly(footer: [
bool(false)
#linebreak()
bool(false)
])
```
$v = false;
var_dump(--$v);
$v = false;
var_dump(++$v);
```
]
#only(2)[
PHP $>= 8.3$
#codly(footer: [
Warning: Decrement on type bool has no effect, ...
#linebreak()
bool(false)
#linebreak()
Warning: Increment on type bool has no effect, ...
#linebreak()
bool(false)
])
```
$v = false;
var_dump(--$v);
$v = false;
var_dump(++$v);
```
]

== `++`/`--` with `true`

#only(1)[
PHP $<= 8.2$
#codly(footer: [
bool(true)
#linebreak()
bool(true)
])
```
$v = true;
var_dump(--$v);
$v = true;
var_dump(++$v);
```
]
#only(2)[
PHP $>= 8.3$
#codly(footer: [
Warning: Decrement on type bool has no effect, ...
#linebreak()
bool(true)
#linebreak()
Warning: Increment on type bool has no effect, ...
#linebreak()
bool(true)
])
```
$v = true;
var_dump(--$v);
$v = true;
var_dump(++$v);
```
]

== `++`/`--` with `string`

#only(1)[
PHP $<= 8.2$
#codly(footer: [
int(-1)
#linebreak()
string(1) "1"
])
```
$v = "";
var_dump(--$v);
$v = "";
var_dump(++$v);
```
]
#only(2)[
PHP $>= 8.3$
#codly(footer: [
Deprecated: Decrement on empty string is deprecated as non-numeric
#linebreak()
int(-1)
#linebreak()
Deprecated: Increment on non-alphanumeric string is deprecated
#linebreak()
string(1) "1"
])
```
$v = "";
var_dump(--$v);
$v = "";
var_dump(++$v);
```
]

== `++`/`--` with `string`

#codly(footer: [string(2) "AA"])
```
$s = "Z";
var_dump(++$s);
```<inc-string-1>

#codly(footer: [string(2) "Z "], offset-from: <inc-string-1>)
```
$s = "Z "; // Trailling space, deprecated as of 8.3
var_dump(++$s);
```<inc-string-2>

#codly(footer: [string(2) " A"], offset-from: <inc-string-2>)
```
$s = " Z"; // Leading space, deprecated as of 8.3
var_dump(++$s);
```

== `++`/`--` with `string`: what could go wrong

#only(2)[
  #codly(footer: [float(50)])
]
```
$s = "4y6";
for ($i = 1; $i < 100; $i++) {
    $s++;
}
var_dump($s);
```

#focus-slide()[
  #align(horizon+center, "WAT")
]

== Explanation

#codly(footer: [string(3) "5e0"])
```
$s = "5d9";
var_dump(++$s);
``` <inc-string-explanation>

#codly(offset-from: <inc-string-explanation>, footer: [float(6)])
```
var_dump(++$s);
```

== When does `strict_types` have an effect?

- String
- Integral and String
- Numeric
- Logical
- Comparative
- #only(1)[Function]#only(2)[#highlight[*Function*]]
- "Special" type juggling contexts
  - Increment/Decrement operators
  - Array offsets
  - String offsets
  - `exit()` prior to PHP 8.4

== What does `strict_types` do?

Only enabled in PHP scripts that use `declare(strict_types=1);`

Disables coercion of scalar types in the following cases *only*:
- Arguments passed to function calls made in userland
- Return value for user defined functions
- Value assignment to a typed property

== `strict_types` does not change binary ops

#codly(footer: [
  int(55)
  #linebreak()
  string(7) "1 hello"
])
```
declare(strict_types=1);
var_dump(10 + "45");
var_dump(true . " hello");
```

== `strict_types` does not change compare ops

#codly(footer: [
  bool(true)
  #linebreak()
  bool(true)
  #linebreak()
  bool(false)
])
```
declare(strict_types=1);
var_dump("1" == "01");
var_dump(14 == "014");
var_dump([] > true);
```

== `strict_types` does not change engine calls

#codly(footer: [`array(3) {
  [0]=>
  string(1) "1"
  [2]=>
  int(3)
  [4]=>
  string(3) "5.0"
  [6]=>
  bool(true)
}
`])
```
declare(strict_types=1);
$is_odd = fn (int $i): bool => (bool) ($i % 2);
$a = ['1', '2', 3, 4, '5.0', '6.0', true, false];
var_dump(array_filter($a, $is_odd));
```

== Hot take

#align(center+horizon)[The `strict_types` declare was a _*mistake*_.]

#focus-slide[
  #align(center)[Thank you!]
]

#bibliography("biblio.bib")