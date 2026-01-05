#import "@preview/touying:0.6.1": *
#import themes.simple: *
#import themes.metropolis: *
#import "base.typ": *
// └─ type:

#set text(font: "Jost")
// #set text(font: "CommitMonoLigaLight")
#set raw(syntaxes: "rise.sublime-syntax")
// #set raw(syntaxes: "rise.sublime-syntax", theme: "rise.tmTheme")

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  config-info(
    title: [Type Checking a Dependently Typed DSL Supported by Equality Saturation #text(size:.8em, [_... and Friends_])],
    subtitle: [],
    author: [Nate Sandy],
    date: datetime.today(),
    institution: [TU Berlin],

    // logo: image("./img/rustacean-flat-happy.svg", width: 1.5em, height: 1em),
  ),
)
#set figure.caption(position: top)
#set image(fit: "contain")
#show raw: set text(font: "JetBrains Mono", size: 17pt)

#let inlinebox(c) = box(
  c,
  outset: (y: 3pt),
  inset: (x: 5pt),
  radius: .2em,
  stroke: rgb("#f7b983") + 2pt,
)

#show raw.where(block: true): set block(
  inset: .5em,
  stroke: rgb("#f7b983") + 3pt,
  radius: .2em,
  width: 100%,
)
#show cite: set text(size: 15pt)
#set list(marker: [--])
#set strong(delta: 100)
#set par(justify: true)
#let todo = box(
  fill: red,
  inset: .25em,
  text(fill: white, weight: "bold")[TODO],
)
#let hl(it) = box(
  text(weight: "medium", align(center)[#it], size: 0.8em),
  inset: (x: .2em, y: .2em),
  radius: .2em,
  baseline: .2em,
  fill: rgb("#f7b983"),
)

#let cover = place(
  top,
  dx: -50%,
  dy: -50%,
  box(width: 200%, height: 200%, fill: rgb("#fafafacc")),
)

// #show heading.where(level: 1): {
//   set heading(numbering: "1.")
// }

#let mono(s) = {
  set text(font: "JetBrains Mono")
  s
}
#let gray(s) = {
  set text(fill: black.transparentize(80%))
  s
}
#let bold(s) = {
  set text(weight: 600)
  s
}

#title-slide()

// == Outline <touying:hidden>
// - #rise
// -
//
// #components.adaptive-columns(outline(depth: 1, title: none, indent: 1em))

= Feel free to ask questions\ during the talk! <touying:unoutlined>


= #rise
== #rise: Motivation
#{
  set table(
    stroke: (x, y) => (
      left: if x > 0 {
        0.8pt
      },
      top: if y > 0 {
        0.8pt
      },
    ),
  )
  align(
    center,
    table(
      align: center,
      columns: (1fr, 1fr),
      inset: .8em,
      bold[Functional Programming], bold[Imperative/GPU Programming],
      [Lists], [Arrays],
      [Recursion], [Iteration],
      [Immutability], [Mutability],
      [High-Level], [Low-Level],
      // [Composable], [Monolithic],
      [Composition], [Control-Flow],
      table.cell(stroke: none, colspan: 2, "")
    ),
  )
  align(
    center,
    table(
      align: center,
      columns: (1fr, 1fr),
      inset: .8em,
      bold[Functional Programming], bold[Imperative/GPU Programming],
      gray[Lists], [*Arrays*],
      gray[Recursion], [*Iteration*],
      [*Immutability*], gray[Mutability],
      [*High-Level*], gray[Low-Level],
      // [*Composable*], gray[Monolithic],
      [*Composition*], gray[Control-Flow],
      table.cell(colspan: 2, mono("-> ") + rise + mono(" <-"))
    ),
  )
}

// drop $$
// // tilde unat on top
// add ßc not 0
// show long term
// multirewrite confusing notaiton
// when are we done
// correctness loaded term
// ccoreectness 2.: side ondition
// is not zero: ntoo optimistic

== #rise: Showcase
#slide[
  #figure(
    ```rise
    def       map : {n : nat} → {s t : data} → (s → t) → n·s → n·t
    def transpose : {n m : nat} → {t : data} → n·m·t → m·n·t
    def      take : (n : nat) → {m : nat} → {t : data} → (n+m)·t → n·t
    def     split : (n : nat) → {m : nat} → {t : data} → (m*n)·t → m·n·t
    ```,
    caption: [Some of #rise's primitives],
  )
  #figure(
    ```rise
    fun mTile nTile : nat =>
    fun {d : data} => fun {m n : nat} =>
      fun c : m·n·d =>
        c |> split (mTile : nat)
          |> map (transpose >> split (nTile : nat) >> map transpose)
          |> join
    └─ type: (mTile nTile : nat) → {d : data} → {m n : nat}
    --       → m·n·d → (m/mTile)*(n/nTile)·mTile·nTile·d
    ```,
    caption: inlinebox(`tiling2D`),
  )
]

// #pagebreak()
// ```lean
// inductive TypedRExprNode where
//   | bvar (deBruijnIndex : Nat) (name: Name)
//   | const (name : Name)
//   | lit (val : RLit)
//   | app (fn arg : TypedRExpr)
//   | depapp (fn : TypedRExpr) (arg : RKindWrapper)
//   | lam (binderName : Name) (binderType : RType) (body : TypedRExpr)
//   | deplam (binderName : Name) (binderKind : RKind) (body : TypedRExpr)

// ```
// ```lean
// inductive RType where
//   | data (dt : RData)
//   | fn (binderType : RType) (body : RType)
//   | pi (binderKind : RKind)
//        (binderInfo : RBinderInfo) (name : Name) (body : RType)
// ```
// #pagebreak()
// ```lean
// inductive RData
//   | bvar (deBruijnIndex : Nat) (name : Name)
//   | mvar (id : Nat) (name : Name)
//   | array  : RNat → RData → RData
//   | pair   : RData → RData → RData
//   | index  : RNat → RData
//   | scalar : RScalar → RData
//   ...
// ```
// ```lean
// inductive RNat
//   | bvar (deBruijnIndex : Nat) (name : Name)
//   | mvar (id : Nat) (name : Name)
//   | nat  (n : Nat)
//   | plus (n : RNat) (m : RNat)
//   ...
// ```
// === Reminder: We do not evaluate #rise programs!
= Type Checking & Inference
== Type Checking & Inference
#place(
  top + right,
  dy: 0%,
  box(
    width: 50%,
    ```rise
      def add : {t : data} → t → t → t
    ```,
  ),
)
// - #rise primitives are typed\ $=>$ There is not much to infer
- Inferring lambda binders: Given ```rise fun x => add 1.0f32 x```, we
  - assign an #text(fill:orange,[*unknown*]) type $meta(t)$ to `x` of kind ```rise data```
  - find concrete types where `x` is used (```rise add 1.0f32 : f32 → f32```)
  - check that usages of `x` don't conflict with each other
  - substitute $meta(t)|->#r("f32")$ in the type of the expression
    - ```rise fun x => add 1.0f32 x : f32 → f32 ```

// === #text(fill:orange,[Meta])variables: One powerful implementation detail
// - Parametric polymorphism: ```rise id : {a} → a → a```
// - Implicit parameters
// - Type inference
#pause
#context place(
  horizon + right,
  $lr(\}#v(3.2cm) )$ + [Unification],
  dx: -7%,
  dy: 25pt,
)
== Unification
Every implicit parameter and unknown type generates one metavariable.

Every non-dependent application generates one unification goal.

=== Unification attempts to find a substitution that makes both sides of all unification goals equal.

// === In #rise, we want to solve all unification automatically.

```rise
def take : {m : nat} → {t : data} → (n : nat) → (n+m)·t → n·t
def xs : 5·f32
take (10 : nat) xs

```
$
  #r("(10 +")meta(m)#r(")·")meta(t) &~ #r("5·f32") \
&arrow.double.b \
meta(t) &~ #r("f32") \
#r("10 +")meta(m) &~ #r("5") &arrow.zigzag \
$

== Unification: Split approach
#slide[
  #{
    set text(font: "Libertinus Serif")
    align(
      center,
      stack(
        spacing: 10%,
        dir: ltr,
        ir(
          $G union {f(s_0,dots,s_k) uni f(t_0,dots,t_k)}$,
          $G union {s_0 uni t_0,dots,s_k uni t_k}$,
          label: [U-Decompose],
        ),
        $...$,
      ),
    )
  }
  #pause
  #bold[This rule is unsuitable for #r("nat")s.]
  #pause

  We split up unification into $unat$ and $udata$, and decompose our #r("data") types accordingly.
  #{
    set text(font: "Libertinus Serif")
    align(
      center,
      stack(
        spacing: 10%,
        dir: ltr,
        ir(
          $G union {n#r("·")t udata m#r("·")u}$,
          $G union {n unat m, t udata u} & &&$,
          label: [UD-Decompose-Array],
        ),
        $ ... $,
      ),
    )
  }

  === Unification of #r("nat")s is essentially the same as solving equations for metavariables!
  #align(
    center,
    stack(
      dir: ltr,
      spacing: 1cm,
      $
        #r("4 * 128 * 128") &unat meta(m)#r("* 4") \
      meta(n)#r("* 4 * 128 * 128") &unat #r("b")^#footnote[#r("b") is a bound variable in the #rise input program.] \
      meta(p)#r("* 128") &unat meta(m) \
      $,
      $=>$,
      $
        meta(m) &unat #r("16384") \
      meta(n) &unat #r("b / 65536") \
      meta(p) &unat #r("128") \
      $,
    ),
  )
]
// We will evaluate multiple approaches to do this:
// - Computer Algebra Sytem (#bold[SymPy]) for $unat$
// - Equality Saturation (#bold[egg]) for both $unat$ and $udata$#footnote[Solving $udata$ is omitted here - details in the thesis.]
// - Syntax-guided Synthesis (SyGuS) for $unat$
== SymPy
#slide[
  - Python library for *symbolic* computation
    - Solutions may include variables that we do not want to solve for:\ Those that are bound variables in the #rise input program.
  - Correctness not guaranteed
  - Only solves $unat$
]
== Equality Saturation

// === A team that needs no introduction
// - E-Graph: Data-structure that stores terms and equalities between them
//   - E-Node: represents a term of a given language; children are e-classes
//   - E-Class: set of e-nodes that are considered equal
//   - Analysis: Allows hooking into e-graph operations, e.g. for constant folding
// - Equality Saturation#footnote[Why does no one ever say E-Saturation?]: Apply rewrite rules until some limit is reached

=== Solving $unat$
// 1. Provide a language (#rise types) and pattern-based rewrite rules
1. Add all unification goals of one #rise program to an e-graph
2. Run equality saturation
3. Extract a substitution for every metavariable //: #r("(~ (mvar ?a) ?b)")
// 1. extensible using _Analysis_
// #pagebreak()

#import "egr_uni.typ"
#align(
  center,
  scale(
    85%,
    reflow: true,
    grid(
      columns: (1fr, 1em, 1fr, 1em, 1fr),
      gutter: 1cm,
      egr_uni.d1, $=>$, egr_uni.d2, $=>$, egr_uni.d3,
      [Add\ #r("(~ 5 (+ (mvar a) 1))")],
      [],
      [Apply rewrite#footnote[Note that here #r("?a") is a _pattern_ variable of the rewrite, while before $meta(a)$ was a metavariable.] $ &#r("(~ ?c (+ ?a ?b))")\ -> &#r("(~ (- ?c ?b) ?a)") $],
      [],
      [Constant folding\ through _analysis_],
    ),
  ),
)
#pagebreak()
=== Essential rewrite rules to isolate metavariables
Properties of equality: applying the same operation on both sides of an equation.
$
  &#r("(~ ?a (/ ?b ?c))") &&-> #r("(~ (* ?a ?c) ?b) if is_not_zero(?c)") \
&#r("(~ ?a (* ?b ?c))") &&-> #r("(~ (/ ?a ?c) ?b) if is_not_zero(?c)") \
&#r("(~ ?a (+ ?b ?c))") &&-> #r("(~ (- ?a ?c) ?b)") \
&#r("(~ ?a (- ?b ?c))") &&-> #r("(~ (+ ?a ?c) ?b)") \

// &#r("   ?p = (mvar ?a),")\
&#r("(~ (mvar ?a) ?b)") &&~> #r("(mvar ?a)") = #r("?b") \
$
These rules lead to solutions such as:
$
  meta(m) unat &#r("(- (- (* 2 (/ (- (+ 1 (+ (+ 1 (+ (/ (bvar h_1) 2) 3)) 0)) 2) 1)) 1)") \
  &#r("   (- (+ 2 (* 2 (/ (bvar h_1) 2))) (bvar h_1)))")
$
#pagebreak()
#slide[
  === Rewrite rules for simplification (sample)
  $
    #r("(+ ?a ?b)") &-> #r("(+ ?b ?a)") \
  #r("(- ?a ?a)") &-> #r("0") \
#r("(+ ?a (+ ?b ?c))") &-> #r("(+ (+ ?a ?b) ?c)") \
#r("(+ ?a (- ?b ?c))") &-> #r("(- (+ ?a ?b) ?c)") \
#r("(/ ?a (/ ?b ?c))") &-> #r("(* ?a (/ ?c ?b)) if is_not_zero(?c) if is_not_zero(?b)") \
&...
  $
  // #pause

  With these rules (and constant folding), we can simplify the previous term to $ meta(m) unat #r("(+ (- (+ (bvar h_1) 6) 1) -2)"). $

  #pause
  #align(center, [🤔])
]


= Evaluation
== Performance
#slide[
  #let mmm = $meta(m) unat #r("(- (- (* 2 (/ (- (+ 1 (+ (+ 1 (+ (/ (bvar h_1) 2) 3)) 0)) 2) 1)) 1) (- (+ 2 (* 2 (/ (bvar h_1) 2))) (bvar h_1)))")$
  #{
    set align(center)
    [
      Input: 30 unification goals
      #grid(
        columns: 4,
        align: (right, left, left),
        gutter: 1em,
        grid.header(
          bold[Approach],
          bold[Time],
          bold[$meta(m)$ resolves to],
          [],
        ),
        [SymPy], [\~600ms],
        [#r("(+ (bvar h_1) 3)")],
        // #pause
        [],

        [egg, 10 iterations:], [\~35s],
        [#r("(+ (- (+ (bvar h_1) 6) 1) -2)")],
        [],
        [egg-phased, 5 iterations:], [\~1s], [#r("(- (+ 1 (+ (bvar h_1) 4)) 2)")],
        [],
        [egg-phased, 10 iterations:], [\~10s], [#r("(+ (bvar h_1) 3)")],
        [],
      )
    ]
  }
  // #pause
  === egg-phased:
  1. Run first ruleset to isolate #r("mvar")s
  2. Extract unsimplified solutions and add them to a new e-graph
  3. Run simplification rules on new e-graph
  4. Extract simplified terms
]
== Correctness?
// What if we need to find that the goals will never unify?
#bold[SymPy]: Returns 0 solutions or more than 1 solution for problematic goals, but 100% correctness not guaranteed.
// - Will find contradictions for us
// - If result contains either 0 solutions or more than 1 solution, _something_ is wrong.
// - No guarantee

=== Equality Saturation
// #bold[2.] Finding contradictions in metavariables
#bold[Termination]: Isolation rules saturate the e-graph. ✅

#bold[Soundness]: What if we need to determine that the goals will never unify?

We need this rule to solve for metavariables:
$
  &#r("(~ (mvar ?a) ?b)") &&~> #r("(mvar ?a)") = #r("?b") \
$
But with input like this, we would end up with $#r("a+b") = #r("a-b")$ in the e-graph:
#align(
  center,
  stack(
    spacing: 4em,
    dir: ltr,
    $meta(m) &unat #r("a+b")$,
    $meta(n) &unat #r("a-b")$,
    $meta(m) &unat meta(n)$,
  ),
)
// mention not_zero could become zero

// identifying mvars is potentially dangerous (no rise example though)
// ?m = a+b
// ?n = a-b
// ?m = ?n
// (- (+ ?a ?b) ?c)
// (term_mvar n_1) = (+ (- (+ (term_bvar h_1) 6) 1) -2)
// == SymPy
// == SyGuS
// == Performance
// sympy 600ms
// eqsat 10sec, while still not done
// n_1 in upsamp
// = Discussion
// sympy fast but possibly not extensible

// egg is slow but extensible
== Conclusion & Future Work
// === Bigger picture
This was an exploration of automated first-order E-Unification of natural numbers.

An ideal solution would be #bold[fast] (enough), #bold[extensible], #bold[explainable], and #bold[proven correct].

Neither #bold[SymPy] nor #bold[egg] are ideal.

#bold[Possible alternatives]: P-Graphs, Syntax-Guided Synthesis, egglog, Metatheory.jl, SymbolicSMT.jl
#align(center, line(length: 50%))
=== Extensions
- #rise has other kinds, e.g. #r("nat2nat")
- Generate side conditions such as "`b` must be divisible by 4" or "`b` must be larger than `a`"
- Prove results with SMT

#bold[Bigger picture]: Automated, _extensible_ unification would allow us to use it in other languages with different features.



= Thanks for listening!
#show: appendix
// $meta(a) -> meta(b) ~ meta(c) -> meta(a)$
#pagebreak()
== Syntactic Fist-Order Unification: Martelli-Montanari-Algorithm <touying:hidden>
#{
  set align(center)
  {
    set text(font: "Libertinus Serif")
    // place(dx:88%,dy:47%,$#r("nat")arrow.zigzag$)
    // place(dx:88%,dy:09%,$#r("nat")arrow.zigzag$)
    include "mmrules.typ"
  }
  // set text(font: "Jost")
  pause
  (
    place(
      center + horizon,
      scale(
        rotate(
          -25deg,
          box(
            stroke: 2pt + red,
            radius: .5em,
            fill: white,
            inset: 1em,
            [Unsuitable for #r("nat")s],
          ),
        ),
        150%,
      ),
    )
  )
}
== More #rise
#figure(
  ```rise
  fun {d : data} => fun xs : d × d => xs.1 * xs.2
  └─ type: {d : data} → (d × d) → d
  ```,
  caption: inlinebox(`prodMult`),
)
#figure(
  ```rise
  fun {n : nat} =>
    fun as bs : n·f32 =>
       zip as bs |> map $prodMult |> reduce add 0.0f32
  └─ type: {n : nat} → n·f32 → n·f32 → f32
  ```,
  caption: inlinebox(`dot`),
)
#figure(
  ```rise
  fun {n m p : nat} =>
    fun a : m·n·f32 =>
    fun b : n·p·f32 =>
      a |> map (fun aRow =>
        transpose b |> map (fun bCol => $dot aRow bCol)
      )
  └─ type: {n m p : nat} → m·n·f32 → n·p·f32 → m·p·f32
  ```,
  caption: inlinebox(`matmul`),
)
#{
  scale(
    figure(
      ```rise
      def weights : 4·f32 -- usually defined

      fun h w : nat =>
        fun input : h+3·w+3·f32 =>
          input |>
          $padClamp2D (1 : nat) (4 - h%2 : nat)
                      (1 : nat) (4 - w%2 : nat)
          >> map (slide (4 : nat) (2 : nat))
          >> slide (4 : nat) (2 : nat)
          >> map transpose
          >> map (map (map ($dot weights) >> $dot weights))
      └─ type: (h : nat) → (w : nat) → h+3·w+3·f32 → (h/2)+3·(w/2)+3·f32
      ```,
      caption: inlinebox(`downsample2D`),
    ),
    // 80%,
  )
}
== SymPy: Example input and output
```python
import sympy as sp
m, n, p, b = sp.symbols("m n p b", integer=True, positive=True)
eq0 = sp.Equality(4 * 128 * 128, m * 4)
eq1 = sp.Equality(n * 4 * 128 * 128, b)
eq2 = sp.Equality(p * 128, m)
res = sp.solvers.solve((eq0, eq1, eq2), (m, n, p), dict=True)
if len(res) != 1:
    raise ValueError("did not find unique solution!")
print(res[0])
```
```py
{m: 16384, n: b/65536, p: 128}
```
=== Correctness Equality Saturation
#bold[1.] Finding contradictions in bound variables

While this contradiction is easy to spot, we might not find a more complex one in time.
#stack(
  dir: ltr,
  spacing: 1cm,
  box(
    width: 45%,
    ```rise
    fun a b : nat =>
    fun xs : 100·f32 =>
      add (split (a+b : nat) xs)
          (split (a-b : nat) xs)
    ```,
  ),
  $=>$,
  $
    #r("a-b") &unat #r("a+b") quad arrow.zigzag\
    meta(m_3) &unat meta(m_5) \
    meta(m_3) #r("*(a-b)") &unat #r("100") \
    meta(m_3) #r("*(a+b)") &unat #r("100") \
  $,
)
// we need to prove correct not just the given unification goals, but also all steps in between.

#slide[
  #bold[3.] Dividing by 0

  We need this rule:
  $
    #r("(/ ?a (/ ?b ?c))") &-> #r("(* ?a (/ ?c ?b)) if is_not_zero(?b)")
  $
  But `?b` could later _become_ `0`, so we should never have applied this rule.

  $
    #r("(/ 8 (/ (- 2 2) 4))")
  $
]
== #rise: Features
- Dependently typed //#footnote[Terms that types depend on are (mostly) in $NN$] typed
  // - enables precise types & optimizations
- Functional primitives that lack an implementation
- #elevate: Rewrite rules for optimization
  - ```rise map (f >> g)``` $arrows.lr$ ```rise map f >> map g```
  - ```rise transpose (transpose x)``` $arrow.r$ ```rise x```
- Staged compilation: #rise programs are not evaluated
  #text(top-edge: 1em)[- #rise $attach(->,t:#elevate)$ #rise $->$ DPIA $->$ C]
== #rise in Lean: Why?
=== Previously: Scala 2
- Porting to Scala 3 was unsuccessful
- Proofs are separate from implementation
=== In this thesis: Lean -- Interactive proof assistant & functional programming language
- Highly extensible (We embed #rise as a DSL)
- Great tooling#footnote[... until you use FFI] (LSP, VSCode extension, ...)
  - Highly interactive REPL-like workflow with `#eval`
- Future work may prove properties of #rise, #elevate, and later stages\ $=>$ Single source of truth
== Conclusion
- #bold[Lean] was a good choice for #rise
  - Success of lowering and proving properties remains to be seen
- #bold[SymPy]
  - performant enough for our purposes
  - results are only trusted -- not proven
  - only solves $unat$, not $udata$
  - easy to use
- #bold[egg]
  - struggles with performance (arithmetic simplification) and correctness
  - extensible via new rules
  - solves both $unat$ and $udata$
  - requires expertise
