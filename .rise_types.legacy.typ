
// ====== Introduction and Elimination Rules

// ===== Typing Rules
// ====== Structural Rules
// ====== misc
// #q[no implicit parameters mentioned? not necessary?]

// #q[All of the rules need names.]
// ===== Well-formed types
// ====== Kinds
// ====== Kinding Structural Rule
// ====== Type Equality
// #c[$tack.double$ means "this statement is true in all interpretations or models.". "semantic entailment". i don't get it.]
// #c[otherwise, this means: if $sigma(N) = sigma(M)$ for all possible substituions
//   $sigma$ (which map free variables to natural numbers), then $N equiv M$]
// eqsat
// ====== Address Spaces
// ====== Nat to Nat Type Level Functions
// #q[why do we need $n$ in the context to judge $M : "nat"$? why is $M$ uppercase but $n$ isn't?]
// #c[$n$ is a variable name, $M$ is a (natural number) term]
// ====== Nat to Data Type Level Functions
// ====== Natural Numbers
// #c[i'm guessing that $underline(ell)$ is a #underline("l")iteral natural number]
// q[$n$ is now lowercase, ok. it's on the left of $tack$. dependent type?],
// [dep array, ft actually takes idx, row length depends on row index],
// c[might wanna write $F_D$ instead, to align with $F_N$],
// ====== Types
// #c[so in other words, $k eq.not "type".$ what's addrSpace used for anyways?]
// $kappa eq.not "type"$,
// #q[If this is a split context (#link("https://ncatlab.org/nlab/show/split+context")), then it seems it's written the _other_ way around here compared to usually as $Gamma | Delta$. It means the judgements in $Delta$ may depend on the judgements in $Gamma$, but not the other way around.]
// #q[ftv (free type variables?) should be a side condition.]
//
//
//
//
// T in vec type must be scalar?
//
#import "base.typ": *
// #import "@preview/curryst:0.5.1": rule, prooftree

// rapid prototyping
// rewrites over primitives, whether they are semantics preserving not important (for now)
// lean reasoning Array ::::
// build dsl
// type checker
//

// -- we could have also used only one app instead of app and depapp, but then we need to extend rexpr such that a single rnat, rdata, rtype... is also an rexpr, because app takes two rexpr. but then a single rdata is a valid rexpr (e.g. `f32`), which doesn't make sense. so instead, we will parse something like `($f ($t:rtype : $k:rkind))
// -- (TODO: insert depapp implementation here)


==== Problem Description

In this work, we will explore the feasibility and implications of using equality
saturation (_EqSat_) for dependent type checking. EqSat is a rewriting technique
that finds equalities between terms, given a number of rewrite rules. Dependent
types are types which _depend_ on terms. They are most prevalent in proof
assistants and known to be highly expressive, but also difficult to use. As
dependent type expressions become sufficiently complex, equality does not get
resolved automatically by definitional equality, and users need to prove
equality manually. By using EqSat to automate this aspect of working with
dependent types, we aim to ease their usage.

// We will now describe concrete issues that show this difficulty.
//  When using dependent types, it is often necessary to prove to the type system that two types are equal, precisely because of the terms contained within the type.

// For example, using a list of values encoding its length `List A (n+m)`, one might need to show that the type `List A (1+m+n-1)` is equal.

In order to try out our approach to type equality checking, we will implement
the grammar and type system of the dependently typed DSL #rise
@hagedornAchievingHighPerformance2023 in Lean 4 @mouraLean4Theorem2021. Usually,
ideas like this one are implemented in a minimally viable language (e.g., here a
dependently typed lambda calculus) to show a proof of concept in isolation.
Reimplementing #rise is not strictly necessary to show the idea in action. It is
rather motivated by laying the groundwork to also formalize #rise and prove
semantic preservation of ~~#elevate's rewrite rules~~ rise's compilation model
down to DPIA & C. These goals are however not part of this thesis.

===== #rise
#rise is a functional array language with dependent types - more specifically,
matrices' types store information about their dimensions. For example, a matrix
`A` has type `n.k.f32`. When #rise expressions get optimized (i.e., rewritten),
the types of expressions become more complex and need to be simplified. To do
this, #rise implements a constraint solver for these array types. However, the
constraint solver is implemented manually and doesn't always yield optimal
results. Using EqSat would be helpful here, because

- it would potentially find better results,
- matching and rewriting happen automatically,
- it would be easily extensible by adding more rewrite rules.

// == Lift <plift>
// A separate problem is a formalization #footnote(link("https://github.com/XYUnknown/individual-project/blob/master/src/lift/Primitives.agda#L118")) of the Lift operation `slide` in Agda. A manual proof `slide-lem` is necessary here to prove
// ```rust
// (n sz sp : ℕ) → suc (sz + (sp + n * suc sp)) ≡ suc (sp + (sz + n * suc sp)).
// ```
// Using EqSat here as a proof tactic could potentially show the equality automatically. There are other Lift operations where this approach might be beneficial #footnote(link("https://github.com/XYUnknown/individual-project/blob/master/src/lift/StencilRules.agda")).

==== Outlook

We propose to do _some part of_ type checking with EqSat namely the part where
type checking considers the equality of two type expressions. We think using
EqSat when those two types involve unnormalized natural numbers is beneficial.
However, it is not clear yet which other instances of type checking lend
themselves well to this approach. Identifying this space is part of this work.

// As an initial exploration of feasibility, we will port some of the problems described in @plift to the proof assistant Lean. Thanks to Marcus Rossel's previous work, the `lean-egg` proof tactic #footnote(link("https://github.com/marcusrossel/lean-egg")) allows us to use EqSat for dependent type reasoning in a dedicated proof assistant. This will show whether and which issues arise.

We will then use the insights from that exploration to inform the design of a
minimally viable domain specific language (_DSL_) that is able to express the
problem space. This enables a deep integration of EqSat with dependent type
checking -- an amount of integration that would be difficult to achieve in an
existing language. Specifying the extent of this integration will be part of
this work.

// - Apparently, it is straight-forward to integrate a `by egg` tactic into Lean to solve the Lift problem (in the aforementioned port).

// - Should we find more use cases for our proposed eqsat type checking, the next step could be to define a small DSL (e.g. lambda calculus with dependent types) in which to explore this approach. This would give us a type system with a small core of predefined typing rules, extensible by rewrite rules.

// == Notes

// > Andres: "We should view this as a word problem, not a type checking problem."

// The word problem asks whether two expressions are equivalent w.r.t. a set of rewrite rules. It is undecidable in general. The undecidability would not be a problem for our approach, because we would run eqsat for _some_ amount of time and if we don't finish in time, we give feedback to the user that more type annotations are needed.

// This is related to Sebastian Hack's approach to the same goal: Using the proof assistant Twee and Knuth-Bendix-completion (which is an algorithm that given a set of equations and a reduction ordering, _attempts_ to find a terminating and confluent rewrite system. Hence it solves the word problem for the given algebra, _if_ it is successful.)
#pagebreak()
==== #rise Grammar
#codeblock(```rise
def downSampleWeights : 4·f32

fun h w : nat =>
fun input : h+3·w+3·f32 =>
  input |>
  $padClamp2D
      (1 : nat) (2 + 2*(1 + h/2 - h/2) : nat) -- 1 - h % 2 -- see comment above
      (1 : nat) (2 + 2*(1 + w/2 - w/2) : nat) -- 1 - w % 2
  >> map (slide (4 : nat) (2 : nat))
  >> slide (4 : nat) (2 : nat)
  >> map transpose
  >> map (map (map ($dot downSampleWeights) >> $dot downSampleWeights))
```)

$
  e ::= &#r("fun") x #r("=>") e |
  #r("fun") x : tau #r("=>") e
  &"Abstraction" \
  | &e thick e | e #r("(")e#r(")") &"Application" \
  | &e #r("(")n #r(":") delta#r(")") &"Dependent Application" \
  | &x &"Identifier" \
  | &underline(l) &"Literal"\
  | &P &"Primitive"\
  \
  kappa ::= &#r("nat") &"Natural Number Kind"\
  | &#r("data") &"Datatype Kind" \
  \
  tau ::= &delta &"Datatype" \
  | &delta #r("→") delta &"Function Type" \
  | &#r("(")x #r(":") kappa#r(") →") tau | #r("{")x #r(":") kappa#r("} →") tau &#h(1cm)"Dependent Function Type"\
  &&"(explicit/implicit parameter)" \
  \
  n ::= &underline(0) &"Natural Number Literal" \
  | &x &"Identifier" \
  | &n #r("+") n |n #r("-") n| n #r("*") n | n #r("/") n | n #r("^") n &"Binary Operation" \
  \
  delta ::= &n #r("·") delta &"Array Type" \
  | &delta #r("×") delta &"Product Type" \
  | &#r("idx[")n#r("]") &"Index Type" \
  | &s &"Scalar Type" \
  | &n#r("<")s#r(">") &"Vector Type" \
  \
  s ::= &
  #r("natType")
  \ | &#r("bool") \
  | &#r("int")
  | #r("i8") \
  | &#r("i16")
  | #r("i32")
  | #r("i64") \
  | &#r("u8")
  | #r("u16")
  | #r("u32")
  | #r("u64") \
  | &#r("f16")
  | #r("f32")
  | #r("f64")
$
#pagebreak()
==== #rise Type System
// #q[All of the rules need names.]

#q[Most syntax classes are missing. E.g. $N, M$ are (nat?) terms]
===== Well-formed types
====== Kinds
$
    kappa ::= & "type" \
            | & "data" \
            | & "nat" \
  #unimp($|$) & #unimp(nat2data) \
  #unimp($|$) & #unimp(nat2nat) \
  #unimp($|$) & #unimp("addrSpace")
$
====== Kinding Structural Rule
#ir(
  // label: smallcaps[Rule],
  $x : kappa in Delta$,
  $Delta tack x : kappa$,
)
====== Type Equality

// #c[$tack.double$ means "this statement is true in all interpretations or models.". "semantic entailment". i don't get it.]

#c[otherwise, this means: if $sigma(N) = sigma(M)$ for all possible substituions
  $sigma$ (which map free variables to natural numbers), then $N equiv M$]

eqsat

#ir(
  $forall sigma : op("dom")(Delta) -> NN thick . thick sigma(N) = sigma(M)$,
  $Delta tack N equiv M : "nat"$,
)
====== Address Spaces
#unimp(ir(
  $A in {"global", "local", "private", "constant"}$,
  $Delta tack A : "addrSpace"$,
))
====== Nat to Nat Type Level Functions
// #q[why do we need $n$ in the context to judge $M : "nat"$? why is $M$ uppercase but $n$ isn't?]

#c[$n$ is a variable name, $M$ is a (natural number) term]
#ir(
  $Delta, n : "nat" tack M : "nat"$,
  $Delta tack n mapsto M : nat2nat$,
)
====== Nat to Data Type Level Functions
#ir(
  $Delta, n : "nat" tack T : "data"$,
  $Delta tack n mapsto T : nat2data$,
)
====== Natural Numbers
#c[i'm guessing that $underline(ell)$ is a #underline("l")iteral natural number]

#grid(
  columns: 1fr,
  gutter: 1.5em,
  ir(
    $$,
    $Delta tack underline(ell) : "nat"$,
  ),
  ir(
    (
      $Delta tack N : "nat"$,
      $Delta tack M : "nat"$,
      $plus.o in {+,*,dots}$,
    ),
    $Delta tack N plus.o M : "nat"$,
  ),
  ir(
    ($Delta tack F_N : nat2nat$, $Delta tack M : "nat"$),
    $Delta tack F_N M : "nat"$,
  )
)
====== Data Types
#grid(
  columns: ((1fr,) * 3),
  gutter: 1.5em,
  ir(
    label: [DT-Scalar],
    $$,
    $Delta tack "scalar" : "data"$,
  ),
  ir(
    label: [DT-Nat],
    $$,
    $Delta tack "natType" : "data"$,
  ),
  ir(
    label: [DT-Index],
    $Delta tack N : "nat"$,
    $Delta tack "idx"[N] : "data"$,
  ),
)
#grid(
  columns: 1fr,
  gutter: 1.5em,
  ir(
    label: [DT-Vector],
    ($Delta tack N : "nat"$, $Delta tack T : "data"$),
    $Delta tack "vec"[T,N] : "data"$,
  ),
  ir(
    label: [DT-Product],
    ($Delta tack S : "data"$, $Delta tack T : "data"$),
    $Delta tack (S,T) : "data"$,
  ),
  ir(
    label: smallcaps[DT-Array],
    ($Delta tack N : "nat"$, $Delta tack T : "data"$),
    $Delta tack N_circ T : "data"$,
  ),
  // q[$n$ is now lowercase, ok. it's on the left of $tack$. dependent type?],
  ir(
    label: [DT-DepPair],
    ($Delta, n : "nat" tack T : "data"$),
    $Delta tack (n : "nat" ** T) : "data"$,
  ),
  [dep array, ft actually takes idx, row length depends on row index],
  ir(
    label: [DT-DepArray],
    ($Delta tack N : "nat"$, $Delta tack F_T : nat2data$),
    $Delta tack N_(circ circ) F_T : "data"$,
  ),
  c[might wanna write $F_D$ instead, to align with $F_N$],
  {
    ir(
      label: [DT-DepFun],
      ($Delta tack F_T : nat2data$, $Delta tack N : "nat"$),
      $Delta tack F_T N : "data"$,
    )
  },
)
====== Types
#ir(
  label: [T-Data],
  $Delta tack T : "data"$,
  $Delta tack T : "type"$,
)
#ir(
  label: [T-Fun],
  ($Delta tack theta_1 : "type"$, $Delta tack theta_2 : "type"$),
  $Delta tack theta_1 -> theta_2 : "type"$,
)
#c[so in other words, $k eq.not "type".$ what's addrSpace used for anyways?]
#ir(
  label: [T-DepFun],
  (
    $Delta, x : kappa tack theta : "type"$,
    $kappa in {"addrSpace", nat2nat, nat2data, "nat", "data"}$,
  ),
  $Delta tack (x : kappa) -> theta : "type"$,
)
===== Typing Rules
====== Structural Rules
// #q[If this is a split context (#link("https://ncatlab.org/nlab/show/split+context")), then it seems it's written the _other_ way around here compared to usually as $Gamma | Delta$. It means the judgements in $Delta$ may depend on the judgements in $Gamma$, but not the other way around.]
#ir(
  $x : theta in Gamma$,
  $Delta | Gamma tack x : theta$,
)
#ir(
  (
    $Delta | Gamma tack E : theta_1$,
    $Delta tack theta_1 equiv theta_2 : "type"$,
  ),
  $Delta | Gamma tack E : theta_2$,
)
#ir(
  $"prim" : theta in "Primitives"$,
  $Delta | Gamma tack "prim" : theta$,
)
====== Introduction and Elimination Rules

#ir(
  label: smallcaps[L-Abst?],
  ($Delta | Gamma , x : theta_1 tack E : theta_2$),
  $Delta | Gamma tack lambda x.E : theta_1 -> theta_2$,
)
#ir(
  label: smallcaps[L-App?],
  (
    $Delta | Gamma_1 tack E_1 : theta_1 -> theta_2$,
    $Delta | Gamma_2 tack E_2 : theta_1$,
  ),
  $Delta | Gamma_1, Gamma_2 tack E_1 E_2 : theta_2$,
)
// #q[ftv (free type variables?) should be a side condition.]
#ir(
  ($Delta, x : kappa | Gamma tack E : theta$, $x in.not "ftv"(Gamma)$),
  $Delta | Gamma tack Lambda x.E : (x : kappa) -> theta$,
)
#ir(
  ($Delta | Gamma tack E : (x : kappa) -> theta$, $Delta tack tau : kappa$),
  $Delta | Gamma tack E tau : theta[tau slash x]$,
)
====== misc
#q[no implicit parameters mentioned? not necessary?]

