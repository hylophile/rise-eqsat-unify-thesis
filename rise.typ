#import "base.typ": *
= The #rise Programming Language <rise>

#quote(
  block: true,
  [_[P]rograms must be written for people to read, and only incidentally for
  machines to execute._],
  attribution: cite(
    form: "prose",
    <abelsonStructureInterpretationComputer2002>,
  ),
)

In this chapter, we will introduce #rise in full detail. We will first give a
brief tour of #rise's features by showing an example program. Then, we will
present #rise's type system formally. Finally, we will highlight some important
technical aspects of our implementation. This includes giving an overview of our
implementation of type checking #rise programs, which will lead to the most
complex part of type checking, unification, that we discuss in @unif.
== A brief tour of #rise

In @rise-tour, we give a short example program to see #rise's features in
action. The first four lines starting with #r("def") define some of #rise's
primitives. These are functions which explicitly do not have an implementation,
but only a type ascription. Take the first primitive #r("map"), which maps a
function over an array. In conventional functional languages, #r("map") is
implemented with recursion, by pattern matching on the first element of the
array, applying the function, and then recursing on the rest of the array.
Recursion is generally less efficient than iteration due to requiring a stack
frame for each function call. While many recursive functions may be optimized to
use asymptotic space using tail call elimination
@clingerProperTailRecursion1998, this is not always possible. #rise solves the
problem of the inefficiency of recursion by omission: It does not support any
recursion, but rather provides common functional primitives and delays their
implementation to later stages of its compiler framework. To define a primitive,
we name it and declare its type. For #r("map"), the user will provide a function
#r("(s → t)") and an array #r("n·s") of size #r("n") and element type #r("s"),
and will receive back an array of type #r("n·t"), i.e, an array of the same size
and the element type that the provided function maps to. The parameters #r("n"),
#r("s"), and #r("t") written in braces are _implicit_ parameters: The user does
not provide them, but our implementation of type inference will need to infer
what they are. Implicit parameters in #rise are always on the type-level, and we
have to declare their kind. Kinds are to types what types are to terms: They
classify types the same way that types classify terms. The kind #r("nat")
classifies #rise's natural numbers, which are strictly positive integers, i.e.,
excluding zero. The #r("data") kind classifies datatypes, i.e., types whose
terms are concrete values (as opposed to functions). The other primitives given
here are those which will be used in the example program. Notably, we allow
arithmetic on #r("nat")s as seen in #r("split") and #r("join").

The program consists of a single expression (lines 6--11) and creates an
anonymous function that tiles a two-dimensional matrix into #r(
  "(m/mTile)*(n/nTile)",
) tiles of type #r(
  "mTile·nTile·d",
), as can be seen in the inferred type (lines 12--13).
//  The whole program can
// be given a name, say `tiling2D`, to reuse it elsewhere and compose more complex
// programs. We do not do that here but will show later how to.
The syntax $#r("fun") x : tau #r("=>") e$ creates an anonymous function taking
$x$ as argument and having the body $e$. The parameters may be terms or types,
and type-level parameters may be implicit written with braces as before. So this
program takes as arguments the type-level #r("nat")s `mTile` and `nTile` and the
matrix `mat` which will be tiled accordingly. The matrix is annotated with its
type consisting of implicit parameters, which effectively states that this
program works for all#footnote[Note that `mTile` must be divisible by `m`
  without remainder, and `nTile` by `n`, but we cannot express this as a
  constraint in #rise. More on this later.] `m`, `n`, and `d`. In particular,
`d` could be a matrix itself. To perform the tiling, various primitives are used
and applied to the input. Regular term-level function application is written
with a space between function and argument, e.g. #r("map transpose"), but a pipe
operator $x #r("|>") f$ is provided as well. This operator is mere syntax sugar
for function application, but reverses the order such that the program can be
largely read from left to right. In a similar vein, the reverse function
composition operator $f #r(">>") g$ is syntax sugar for
$#r("fun") x #r("=>") g #r("(")f x#r(")")$. Type level application, e.g. #r(
  "split (mTile : nat)",
) which supplies an explicit type-level parameter to #r("split"), is written
with parentheses and an explicit kind ascription. This syntax is not strictly
necessary, but rather an unfortunate result of a myopic grammar definition on
our part. In the future, we intend to support type-level application with
identical syntax as term-level application, i.e., #r("split mTile") in this
case.

While this program only covers a small number of primitives and not the whole
grammar of #rise, it should serve as an adequate overview and prepare for the
remainder of this thesis. A full grammar can be found in #ref(
  supplement: [Appendix],
  <rise-grammar>,
), and most of #rise's primitives that we define are listed in #ref(
  supplement: [Appendix],
  <rise-primitives>,
), which may help to get a better understanding of what is possible with #rise.
// #q[todo]
// immutable, functional, dependently typed,

#figure(
  ```rise
  def       map : {n : nat} → {s t : data} → (s → t) → n·s → n·t
  def transpose : {n m : nat} → {t : data} → n·m·t → m·n·t
  def     split : (n : nat) → {m : nat} → {t : data} → (m*n)·t → m·n·t
  def      join : {n m : nat} → {t : data} → n·m·t → (n*m)·t

  fun mTile nTile : nat =>
  fun {d : data} => fun {m n : nat} =>
    fun mat : m·n·d =>
      mat |> split (mTile : nat)
          |> map (transpose >> split (nTile : nat) >> map transpose)
          |> join
  └─ type: (mTile nTile : nat) → {d : data} → {m n : nat}
  ​         → m·n·d → (m/mTile)*(n/nTile)·mTile·nTile·d
  ```,
  caption: [A #rise program tiling a two-dimensional matrix into tiles of given
    sizes (`tiling2D`).],
) <rise-tour>

#include "rise_type_system.typ"

== Implementing #rise in Lean <rise-impl>

We chose Lean 4 as implementation language for #rise because it offers many
conveniences to embed domain specific languages. It is a reimplementation of the
previous version, with a large part of the motivation being to improve this
experience for users. Lean 4 is written in Lean itself, which allows users to
benefit from and reuse Lean's own infrastructure @mouraLean4Theorem2021. As an
example, we are able to throw errors at specified syntax nodes of _our own_
#rise eDSL using the same function that Lean uses (`throwErrorAt`) to signal
errors to the user, resulting in a localized error and the relevant syntax being
underlined red in the editor.

Defining an eDSL in Lean is part of the discipline of _metaprogramming_. Our
goal is to be able to write a #rise program using our own syntax, and receive
back a #rise expression in the form of a Lean object, where all #rise types are
checked and inferred or an error is raised. In order to produce this object, we
will write code that is one level above actual Lean objects, hence it is
programming at the meta-level (as opposed to the object-level). This
metaprogramming comprises the following stages
@leandevelopersElaborationCompilation2025:
1. Parsing: Transforming a string of #rise code into a syntax tree.
2. Macro Expansion: Transforming syntax sugar to basic syntax.
3. Elaboration: Transforming basic syntax into (in our case) a Lean object that
  describes a #rise expression. This is also where we perform all type checking,
  inferring, and other semantic error handling (such as unknown variables).

We will now show how we implement these three phases.

==== Parsing.
@impl-syntax shows a selection of our syntax definitions for #rise expressions.
We first declare a syntax category `rise_expr` in order to refer back to it
later (line 1). A syntax category groups syntax definitions, just as `ident`
does for identifiers, which is a syntax category defined by Lean. Line 2 thus
declares that identifiers are part of our `rise_expr` syntax category. Following
that (line 3) is our function abstraction syntax. The syntax in double quotes is
used for concrete input string. We allow one or more identifiers and an optional
type ascription, as seen by annotations familiar from regular expressions. Two
consecutive `rise_expr`s are our syntax for term-level application (line 4). The
nodes are annotated with a precedence, specifically which minimal precedence
they must have in order to be parsed. Since application is given a precedence of
`50` (```lean syntax:50```), parsing #r("f g h") as #r("f (g h)") is invalid
because the right node of an application must have at least precedence of `51`.
Thus, only #r("(f g) h") is a valid parsing of #r("f g h"), i.e., these
annotations also make application left-associative. Finally, line 5 declares our
syntax sugar for reverse function composition, which is also left-associative
but has a lower precedence than application, so that #r("f >> g h") is parsed as
#r(
  "f >> (g h)",
) and not #r("(f >> g) h").

#figure(
  caption: [Excerpt of syntax definitions for #rise expressions.],
  ```lean
  declare_syntax_cat                                    rise_expr
  syntax ident                                        : rise_expr
  syntax "fun" ident+ (":" rise_type)? "=>" rise_expr : rise_expr
  syntax:50 rise_expr:50 rise_expr:51                 : rise_expr
  syntax:40 rise_expr:40 ">>" rise_expr:41            : rise_expr
  ```,
) <impl-syntax>

==== Macro Expansion.
To create macros, we use the `macro_rules` command as shown in @impl-macro. The
first macro (lines 2--4) defines how our #r(">>") operator gets transformed into
basic syntax. We use Lean's function `mkIdent` to create an identifier needed
for the anonymous function, which will ensure that the identifier is unique due
to Lean's built-in macro hygiene. The next macro (lines 6--11) shows how an
anonymous function naming multiple parameters of the same type gets turned into
the basic syntax of anonymous functions with single parameters. All macros
transform syntax until they no longer match, so after this phase we are left
with only basic syntax.

#figure(
  caption: [
    Excerpt of macros used for #rise expressions.
  ],
  ```lean
  macro_rules
    | `(rise_expr| $f:rise_expr >> $g:rise_expr) =>
      let x := mkIdent `x
      `(rise_expr| fun $x => $g ($f $x:ident))

    | `(rise_expr| fun $x:ident $y:ident $xs:ident* => $e:rise_expr) =>
      match xs with
      | #[] =>
        `(rise_expr| fun $x => fun $y => $e)
      | _ =>
        `(rise_expr| fun $x => fun $y => fun $xs* => $e)
  ```,
) <impl-macro>

// #pagebreak()
==== Elaboration.
To create the Lean values that describe typed #rise expressions (`TypedRExpr`),
we use one central elaboration function (excerpt shown in @impl-elab). This
function matches on all basic #rise syntax, and returns a `TypedRExpr`
accordingly, or throws an error. The first example match (lines 2--5) shows what
we do when we encounter an anonymous function
$#r("fun") x #r(":") t #r("=>") b$. First, we elaborate the type ascription, for
which we have a separate elaboration function. Then, we elaborate the body,
calling `elabToTypedRExpr` recursively on $b$, while adding $x$ to the term
context. Compare with #smallcaps[R-Abst] in @rise-tyrules, reading it from
bottom to top: We essentially do the same steps, but start with a full #rise
program, so we start at the bottom and attempt to derive a full proof tree,
i.e., elaborate all sub-expressions of this anonymous function without
encountering errors. We then return the according variants of the expression and
its type. Context management and other bookkeeping is done through `RElabM`,
which is an instance of a monad. While the intricacies of monads deserve their
own treatment (or rather, a myriad of treatments #footnote[#link(
  "https://wiki.haskell.org/Monad_tutorials_timeline",
)]), for our purposes they function as syntax sugar, saving us additional
parameters in our elaboration function. (We could also have the term context be
an additional parameter to `elabToTypedRExpr`, and drag the context along with
every invocation. The `Reader` monad saves us from such chores.)

#figure(
  caption: [The main elaboration function for typed #rise expressions
    (excerpt)],
  ```lean
  def elabToTypedRExpr : Syntax → RElabM TypedRExpr
    | `(rise_expr| fun $x:ident : $t:rise_type => $b:rise_expr) => do
      let t ← elabToRType t
      let b ← withNewLocalTerm (x.getId, t) do elabToTypedRExpr b
      return ⟨.lam x.getId t b, .fn t b.type⟩

    | `(rise_expr| $f_syn:rise_expr $e_syn:rise_expr) => do
        let f ← elabToTypedRExpr f_syn
        let f := {f with type := (← implicitsToMVars f.type)}
        let e ← elabToTypedRExpr e_syn
        let e := {e with type := (← implicitsToMVars e.type)}
        match f.type with
        | .fn ftl ftr => do
          addUnifyGoal (ftl, e.type)
          return ⟨.app f e, ftr⟩
        | _ => throwErrorAt f_syn "expected function, found {f.type}"
  ```,
) <impl-elab>

The second match shown here concerns function application (lines 7--16).
Predominantly, what we do here is elaborate both $f$ and $e$ (lines 8 and 10),
ensure that $f$ has a function type (lines 12,13,16), and return the `.app`
variant of #rise expressions having the type `ftr` (line 15), which are all
parameters of $f$ other than the first. But what happens between those lines is
the gateway to the remainder of this thesis: Implicit parameters are turned into
metavariables (`implicitsToMVars` in lines 9 and 11), and the first parameter
type of $f$ along with the type of $e$ are added as one unification goal
(`addUnifyGoal` in line 14). Let us first introduce metavariables. As seen
before, implicit parameters do not occur in #rise's type system, but their
values need to be inferred. Whenever we encounter the binder of an implicit
parameter, we remove the binder, create a fresh metavariable, and replace every
occurrence of that parameter with that metavariable. Metavariables are variables
one level above #rise programs, representing unknown types or type components: A
typed #rise program never contains any metavariables. To achieve this, we need
to find a unique solution for each metavariable. Crucially, these solutions must
result in semantic equivalence within each unification goal. Compare this with
the rules #smallcaps[R-App] and #smallcaps[R-TEquiv] of @rise-tyrules: In order
for an application to be valid, the argument must have the same type as the
first parameter type of the function. Through #smallcaps[R-TEquiv], we can also
consider those types to be the same type if they are semantically equivalent.
That is why whe add these types as one unification goal at this point. If we can
then later find solutions for all metavariables such that all unification goals
are semantically equivalent (which is called unification), the #rise program
typechecks.

This concludes our chapter about #rise's syntax, type system, and aspects of its
implementation. It should come as no surprise that we will now discuss our
approaches of solving unification at length.

