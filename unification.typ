#import "base.typ": *
#import "egr_uni.typ"


// #set page(height: auto) // remove

= Solving Unification Using Various Approaches <unif>
In this section, we will describe the most complex part of type checking and
inference in #rise: unification. We begin by explaining what unification is and
how we adapted it to fit our purposes, and continue with describing multiple
approaches that we took to solve it. @discus will then compare those approaches
and discuss their respective advantages and limitations.
== Unification <unif-mm>

Most generally, unification receives as input a finite set of related terms
(unification goals) #box[$G:={l_1 ~ r_1, ..., l_n ~ r_n}$], where $~$ is the
unification relation. Those terms may contain variables. Unification will then
attempt to find a substitution $sigma$, which maps variables to terms, such that
for all $l ~ r in G$, $sigma(l) = sigma(r)$. This process is fallible: such a
substitution might not exist.

In our context, the related terms that are to be unified are #rise types. The
variables subject to unification are metavariables, i.e., unknown types (or type
components) that need to be inferred. Note that #rise types may also include
binding and bound variables, which are also unknown types, but _must not_ be
inferred because they represent parameters of the program that are yet to be
provided by the user. To illustrate this difference, we will always prefix
metavariables with a question mark, e.g. $meta(x)$, and write binding and bound
variables without prefix.

If unification fails, i.e., there is no substitution $sigma$ such that
$forall l ~ r in G$ . $sigma(l) = sigma(r)$, then that will indicate a type
error in the input program, because there are some pairs of types that should
have been made equal by $sigma$, but were not. Note that this is different from
an existing, but empty, substitution, which may be valid if there are no
metavariables in the unification goals.

Usually, unification is successful if a substitution is found. However, as
mentioned in @rise-impl, metavariables are not part of the #rise type system,
and typed #rise programs never contain any metavariables. As such, we will only
consider the found substitution suitable if every metavariable resolves to a
term _that does not include any metavariables itself_. This is not merely an
aesthetic choice: If our algorithm cannot find a concrete solution for every
metavariable, then the input program was underspecified. When unification _does_
find a suitable substitution $sigma$, we will then apply $sigma$ to the types of
the input program and communicate the inferred type back to the user.

#figure(
  [```rise
    def take : (n : nat) → {m : nat} → {t : data} → (n+m)·t → n·t
    def xs : 5·f32

    take (10 : nat) xs
    ```
    $
      #r("(10+")metat(m)#r(")·")metat(t) & ~ #r("5·f32") \
                                         & arrow.double.b \
                       #r("10+")metat(m) & ~ #r("5")      & arrow.zigzag \
                                metat(t) & ~ #r("f32") \
    $],
  caption: [A minimal example of the unification we intend to implement. A
    single unification goal is generated which attempts to unify two array
    types. After decomposing and unifying the length and element type components
    of both array types, we find that there is no $meta(m) in nat$ such that
    $#r("10+")metat(m) &~ #r("5")$ is true.
  ],
  kind: image,
) <uni-ex>


Before we treat the definition of unification more formally, we will consider an
example. @uni-ex shows a short #rise program which attempts to #r("take") 10
elements from an array that is only 5 elements long --- a program which must not
typecheck. To arrive at this conclusion, we first consider the application #r(
  "take (10 : nat)",
), which supplies #r("10") to #r("take"). Every #r("n") in its type is
substituted with #r("10"), so #r(
  "take (10 : nat) : {m : nat} → {t : data} → (10+m)·t → 10·t",
). Next, we supply #r("xs") to #r("take (10 : nat)"). The leftmost parameters of
#r("take (10 : nat)") are implicit parameters. For each implicit parameter, we
generate a fresh metavariable, and substitute the previously bound variables
with the respective metavariables. So now we have
$#r("take (10 : nat) : (10+")metat(m)#r(")·")metat(t)#r(" → 10·")metat(t)$.
Furthermore, the left-hand side of an application must be a function type, and
the type of the right-hand side (#r("5·f32")) must _match_ the first explicit
parameter of the left-hand side's type ($#r("(10+")metat(m)#r(")·")metat(t)$).
This _matching_ is precisely what unification will enforce: Therefore, the
unification goal $#r("(10+")metat(m)#r(")·")metat(t) &~ #r("5·f32")$ is
generated. For two types to be unifiable, first their structure must match.
Since both sides are array types, their structure does indeed match and we can
consider their components. For each component of the left array, we generate a
new unification goal that attempts to unify the component with the respective
component of the right array. The element types resolve to the goal
$metat(t) &~ #r("f32")$, which suggests $meta(t)$ to be replaced with #r("f32").
The length component resolves to the goal $#r("10+")metat(m) &~ #r("5")$.
However, there is no natural number that we can substitute for $meta(m)$ to
satisfy this goal. Thus, unification as a whole ought to fail here, and ideally
report back a reason for why it failed. Now that we have seen the intricacies of
unification in practice, we will look at a more precise definition, which will
also cover special cases that did not occur in the example.

#figure(
  include "mmrules.typ",
  caption: [Syntactic first-order unification rules per #cp(
      <martelliEfficientUnificationAlgorithm1982>,
    ), adapted to use metavariables. $f$ and $g$ denote function symbols, $t$ is
    an arbitrary term, $meta(x)$ is a metavariable, and $G[meta(x)|->t]$
    replaces all $meta(x)$ in $G$ with $t$.],
) <unifrules>


#cp(<martelliEfficientUnificationAlgorithm1982>) devised a unification algorithm
that applies transformations to an input set until no transformation applies, or
until a failure condition is met. We reproduce this algorithm in @unifrules, but
phrase it as a set of inference rules. We also rephrase it to use metavariables,
since those are the unification variables of interest. Each inference rule
represents one transformation, where the premises are the conditions of whether
the transformation is applied, and the conclusion shows how the input set is
transformed. The rules are applied to the input set $G$ as long as any of them
meet the respective premise, and we are left with either $bot$ (i.e.,
unification failed) or a new $G$ that is in the form of a substitution. The
algorithm, and therefore this ruleset, is known to be sound, complete, and
terminating. However, it describes _syntactic first-order unification_, a
special subset of the unification problem. _Syntactic_ refers to terms being
syntactically equal after applying the found substitution. _First-order_ refers
to the unification variables under scrutiny being of first order, i.e.,
variables represent only constants, not functions @baaderTermRewritingAll1998.
We will shortly see why this is not sufficient for #rise types.

Let us now briefly explain the necessity of each of the rules in @unifrules and
relate them to unification of #rise types:
- #smallcaps[U-Decompose] inspects function symbols and, if they match, adds
  their components to the solution set $G$. When the terms are of kind #r(
    "data",
  ), the function symbol $f$ must correspond to a datatype constructor such as
  the array type in the previous example. The rule attempts to unify the type
  components of both sides in the conclusion, which is exactly what we did in
  the example. However, for terms of kind #r("nat"), this rule is unsuitable, as
  the function symbol would correspond to functions over natural numbers. Given
  e.g. $+(meta(x), 1)~+(2, 3)$, it does not follow that $meta(x) ~ 2$.
- #smallcaps[U-Delete] removes trivial solutions.
- #smallcaps[U-Swap] moves variables to the left side, such that the final
  solution set will be in the shape of a substitution.
- #smallcaps[U-Eliminate] eliminates a solved variable in the rest of $G$. In
  practice, this ensures that the resulting substitution only has to be applied
  once.
- #smallcaps[U-Conflict] fails unification when differing function symbols are
  attempted to be unified. This is what we want for #r("data") types: We should
  never unify e.g. an array type with a pair type. For #r("nat")s, this is again
  an unsuitable rule. E.g. $* #h(0em) (2,1)~+(1,1)$ would result in this rule
  matching and failing the unification, even though evaluating the functions
  would yield a valid solution of $2~2$.
- #smallcaps[U-Check] fails unificaiton if a variable _occurs_ in its own
  solution. This needs to fail because it would yield an infinitely nested term
  otherwise.

We can see, that some of these rules are not sufficient
(#smallcaps[U-Decompose]) or even detrimental to our goal
(#smallcaps[U-Conflict]) of unifying the dependent types of #rise. Specifically,
we need to split unification depending on the kind that is to be unified. From
now on, we will write $udata$ ("#r("data")-unify") to express unifying type
components of kind #r("data"), and analogously write $unat$ ("#r("nat")-unify")
to unify #r("nat")s. A more general form or what we dub #r("nat")-unification is
known as E-Unification (Equational unification) or _unification modulo theory_
in the literature: It takes into account semantic properties of function symbols
(such as commutativity of $+$) @baaderTermRewritingAll1998.

For #r("data"), we will use the rules of syntactic first-order unification as
shown above - with one exception: #smallcaps[U-Decompose] needs to match on the
specific type constructors and act according to the kinds of the components
(@decomp-fine). For example, the array type $n_circ t$ is composed of the size
$n$ of the array, which is of kind #r("nat"), and of the element type of the
array $t$, which is of kind #r("data"). So to unify two arrays
$n_circ t udata m_circ u$, we need to unify the sizes $n unat m$ and the element
types $t udata u$. Note that strictly speaking, the function type $t->u$ is not
of kind #r("data"), but this is inconsequential for unification, and therefore
we unify function types also with $udata$.

#let decomp-rules = grid(
  columns: 2,
  gutter: 1.5em,
  grid.cell(
    colspan: 1,
    ir(
      $G union {t -> u udata v -> w}$,
      $G union {t udata v, u udata w} & &&$,
      // label: [UD-Decompose-Fun],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {(t, u) udata (v, w)}$,
      $G union {t udata v, u udata w} & &&$,
      // label: [UD-Decompose-Product],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {"idx"[n] udata "idx"[m]}$,
      $G union {n unat m} & &&$,
      // label: [UD-Decompose-Index],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {"vec"[t,n] udata "vec"[u,m]}$,
      $G union {t udata u, n unat m} & &&$,
      // label: [UD-Decompose-Vector],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {n_circ t udata m_circ u}$,
      $G union {n unat m, t udata u} & &&$,
      // label: [UD-Decompose-Array],
    ),
  ),
);

#figure(
  placement: bottom,
  context {
    let h = measure(decomp-rules).height
    set align(center + horizon)
    stack(
      dir: ltr,
      smallcaps[UD-Decompose-$ast$],
      $lr(\{ #v(h + .9em))$,
      decomp-rules,
    )
  },
  caption: [Fine-grained decomposition rules for #rise types. We recurse with
    $udata$ on components of kind #r("data"), and dispatch to $unat$ for #r(
      "nat",
    )s.],
) <decomp-fine>

We refrain here from giving a precise algorithm for $unat$, as that will depend
on the specific approach taken. Additionally, solving $unat$ is undecidable as
we will show in @completesound. However, the problem statement is familiar to
anyone who has enjoyed high school algebra: We are presented with a system of
(possibly nonlinear) equations, and the goal is to find a unique solution --- if
present --- for every (meta)variable such that every equation in the system
holds. This involves methods such as applying properties of equalities (i.e.,
adding/subtracting/etc. terms on both sides), transforming terms (e.g. applying
commutativity of multiplication), and simplifying terms (e.g. the identity of
subtraction $a-0=a$). Additionally, we want to detect unsatisfiability (e.g.
$X+5 unat X+1$) and should that be present, declare the process as failed.

Now that we have described the unification problem and how it applies to type
checking and type inference in #rise, we will move on to our approaches of
solving unification. In @cas, we will solve $udata$ with the MM-Algorithm and
solve $unat$ with SymPy, and @eqs will present an approach where equality
saturation will solve both $udata$ and $unat$.

== MM-Algorithm + CAS <cas>
For our first approach, we implemented the MM-Algorithm (@unifrules) in Lean to
solve $udata$. While the algorithm is phrased imperatively, an equivalent
version for functional languages is given in #cp(<baaderTermRewritingAll1998>).
We will not describe the details of this implementation here in order to focus
on our own contributions. However, one small change is necessary: Whenever we
encounter a #r("nat")-unification goal (namely, when #smallcaps[UD-Decompose]
visits a datatype that contains a #r("nat")), we collect that goal into a list
$G^NN$. If the MM-Algorithm finishes with a suitable substitution (for variables
of kind #r("data")), we are then left with a list of $unat$-goals. These goals
are given to a Computer Algebra System, specifically SymPy.

SymPy is an open source Python library for symbolic computation. It was
originally started by Ondřej Čertík in 2005, and has since grown to over 1300
contributors#footnote[https://github.com/sympy/sympy/blob/master/AUTHORS]. It
focusses on being easy to use by not being its own programming language, but
rather an embedded domain specific language using Python's operator overloading
functionality @meurerSymPySymbolicComputing2017. SymPy's capability of reasoning
symbolically is important for our purposes: As mentioned before, solutions for
metavariables might still depend on bound variables (i.e., symbols) of the #rise
input program. We also specifically do _not_ want to solve for those bound
variables, but only for metavariables.

While SymPy's age, popularity, and number of contributors speaks towards its
trustworthiness, it is important to note that "[s]olvers in a Computer Algebra
System are based on heuristic algorithms, so it’s usually very hard to ensure
100% percent correctness, in every possible
case"#footnote[https://docs.sympy.org/latest/modules/solvers/solveset.html#how-does-solveset-ensure-that-it-is-not-returning-any-wrong-solution].

As stated previously, our problem of solving $unat$ is akin to solving systems
of possibly nonlinear equations. SymPy employs various methods to solve systems
of equations, depending on whether they are linear, nonlinear, or have other
properties which will not be relevant to us. The systems of equations we will
hand to SymPy _may_ be nonlinear, but may also be linear. One might assume that
since nonlinear equations are a superset of linear equations, we could use the
nonlinear methods to solve all of our inputs. However, SymPy's authors note that
"[...] it is not recommended to solve linear system using `nonlinsolve`, because
`linsolve()` is better for general linear systems"#footnote(
  link(
    "https://docs.sympy.org/latest/modules/solvers/solveset.html#sympy.solvers.solveset.nonlinsolve",
  ),
). Thankfully, SymPy provides a "mature general function for solving many types
of
equations"#footnote[https://docs.sympy.org/latest/modules/solvers/solvers.html#module-sympy.solvers]
in `solve()`, which determines the types of equations that are passed to it, and
chooses a suitable method to solve the system.


#figure(
  caption: [SymPy input and output. Given three unification goals, we generate
    three equalities and solve the system for the metavariables of the input
    (`m`, `n`, and `p` in this case). We also ensure that exactly one solution
    is found, since otherwise unification was not successful.],
  kind: image,
)[
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
] <sympycode>

To integrate SymPy with our Lean implementation, we generate a Python program,
run it as an external process, and parse its output (@sympycode). For every
variable in our unification goals, we generate one `Symbol`. In this example,
`m`, `n`, and `p` are metavariables in the input, and `b` is a bound variable in
the input. (The actual implementation prefixes metavariables with `m_` and bound
variables with `b_` to differentiate between them, but this is omitted here to
remove some syntax noise.) Since #r("nat")s in #rise must be positive integers,
this is also true for all variables, so we annotate all symbols accordingly. We
then generate one `Equality` for each unification goal, and name each of them.
To solve the system of equations, we call `sp.solvers.solve`, giving it all
unification goals and all metavariables as parameters. Finally, we need to
ensure that exactly one solution is found by SymPy --- otherwise, unification
failed. SymPy then returns a dictionary with keys being the names of the
metavariables, and values being their solutions. It is printed to standard out,
which we parse in Lean.



This section showed how we employ SymPy to solve $unat$. Next, we will introduce
equality saturation and show how it can be used to solve both $udata$ and
$unat$.

== Equality Saturation <eqs>

E-Graphs (equality graphs) are a data structure that stores terms and equalities
between terms. Equality Saturation is the process of applying rewrite rules to
the terms in said e-graphs. They are used for program optimization and proving
equalities in equational reasoning. While e-graphs were devised in the late
1970s, recent advances in their implementation have inspired much research
interest. We will use the open-source library `egg` developed by #cp(
  <willseyEggFastExtensible2021>,
) to perform equality saturation in our work. One particularly noteworthy
property of `egg` is its extensibility: We will provide our own language,
rewrite rules for that language, and custom logic (e-graph analysis). This makes
`egg` highly flexible, and hence also viable as a tool to solve unification.

// #pagebreak()

We will not delve too deep into the technical details of e-graphs here, but
rather describe only the concepts necessary to understand our process. An
e-graph consists of _e-nodes_ and _e-classes_. E-nodes represent terms of a
language that we provide. More specifically, the root of an e-node is an
operator or constant in the language. Its children, i.e., the arguments of the
operator, each point to one e-class. In turn, e-classes are sets of e-nodes that
are considered equal. Initially, each e-class only contains one e-node. By
applying rewrite rules on the e-graph, new e-nodes may be added and e-classes
may be merged. Over multiple iterations of rewriting, we then learn of new terms
that are equal to the terms we started out with. This rewriting is
non-destructive; the e-graph never#footnote[Unless we explicitly tell it to.]
deletes any e-nodes or e-classes, but only adds them. This makes e-graphs useful
for optimization of terms. They do not get stuck in a local optimum, because all
optimization steps stay visible in the e-graph. This process of rewriting is
called _Equality Saturation_. The name stems from the fact that while rewriting,
the e-graph may saturate: No rewrite would apply further changes, because all
rewrites have been found. Whether the e-graph saturates depends on the given
rewrite rules. The last important concept is what `egg` calls _Analysis_: It
allows us to attach metadata to each e-class, and hook into the merging process
of e-classes and the process of adding e-nodes. In other words, it allows us to
specialize equality saturation for our purposes by adding custom logic.

Let us now describe a concrete example of equality saturation to see these
concepts in action. In @egraphexample, we first add the unification goal
$5 ~ nmv(a) + 1$
to the e-graph. This creates one e-node for every operator and constant. Each
e-node is in its own e-class, because at this stage, they are all equal to only
themselves. E-nodes point to the respective e-classes (shown as blue rectangle
in the background) of their children. The order of the children matters; this is
visible in the representation of $nmv(a) + 1$, since the edges cross over each
other. While we know that addition is commutative, it is not represented in this
e-graph. In step two, we apply a rewrite rule. The rule searches for all terms
in the e-graph match the left-hand side of the rule, binding terms to pattern
variables $pvar(a), pvar(b), "and" pvar(c)$. The right-hand side may use these
bindings. The right-hand side is then added to the e-graph, and set equal to the
left-hand side. The rule represents the subtraction property of equalities:
subtracting a quantity on both sides of an equation does not change it. Hence we
subtract $1$ on both sides of the unification, adding $5-1 ~ nmv(a)$ to the
e-graph and setting it equal to the unification that we added previously. This
is shown by both unification goals being in the same e-class, i.e., the same
blue rectangle. The third step is then our analysis implementation of constant
folding: The e-classes for both $5$ and $1$ are annotated with the metadata of
them being equal to constants, and which constants. Since both of them are
constants, they can be folded and $4$ is added as a node in the same e-class as
$5-1$.

#let grscale = 80%
#figure(
  caption: [An example of adding a unification goal to an egraph, applying one
    rewrite, and having analysis realize the opportunity of a constant fold.],
  kind: image,
  align(
    horizon + center,
    grid(
      // columns: 5,
      columns: (1fr, 1em, 1fr, 1em, 1fr),
      align: (x, y) => if y == 1 { top } else { center + horizon },
      // column-gutter: 1cm,
      scale(grscale, egr_uni.d1),
      $=>$,
      scale(grscale, egr_uni.d2),
      $=>$,
      scale(grscale, egr_uni.d3),

      [1. Add $5 ~ nmv(a) + 1$ to e-graph.],

      [],
      [
        2. Apply rewrite
          // #footnote[Note that #r("?a") is a _pattern_ variable while $meta(a)$ is a metavariable]
          #v(-5pt)$
               & pvar(c) ~ pvar(a)+pvar(b) \
            -> & pvar(c)-pvar(b) ~ pvar(a).
          $
      ],
      [],
      [3. Constant folding\ through analysis],
    ),
  ),
) <egraphexample>

The advantage of equality saturation is that we supply our own language, rewrite
rules, and analysis to the process. This enables us to solve both $udata$
(syntactic first-order unification) and $unat$ (e-unification) with it. We will
now show in detail how we achieved this. @discus will then discuss advantages
and limitations of the two approaches we explored (SymPy and equality
saturation).

=== Solving $udata$
As shown before, we solve first-order unification by applying the MM-Algorithm
to the input, with the exception of #smallcaps[U-Decompose]. Hence, we will
describe in this section the language, rewrite rules, and analysis that we
employ to translate this algorithm into the framework of equality saturation,
and show how each unification rule (@unifrules and @decomp-fine) corresponds to
which aspect of our implementation.

_The language_. We will use the same language for both $udata$ and $unat$
(@egglang). This consists of all of #rise's currently implemented #r(
  "data",
)types (plus the #rise function type) and all operations on #r("nat")s that we
support. The `Symbol` variant represents arbitrary, and is used for the various
scalar types of #rise such as #r("f32") or #r("int"). Each variant is annotated
with its string representation, the name of the variant, and the number of
children e-classes it has (`Id` is the type that `egg` uses to identify
e-classes). Additionally, we need to represent metavariables and bound
variables, and differentiate variables based on their kind, such that we can use
different rewrite rules on them. The enum is wrapped in the Rust macro
`define_language!` provided by `egg`, which will generate all necessary methods
for us.

#figure(
  caption: [The language we use to solve unification using equality
    saturation.],
  ```rust
  define_language! {
      pub enum RiseType {
          // data
          "array"     = Array([Id; 2]),
          "vector"    = Vector([Id; 2]),
          "pair"      = Pair([Id; 2]),
          "index"     = Index(Id),
          "fun"       = Fun([Id; 2]),
          "data_mvar" = DataMVar(Id),
          "data_bvar" = DataBVar(Id),
          Symbol(Symbol),
          // nat
          "+"        = Add([Id; 2]),
          "*"        = Mul([Id; 2]),
          "/"        = Div([Id; 2]),
          "-"        = Sub([Id; 2]),
          "~"        = Unify([Id; 2]),
          "nat_mvar" = NatMVar(Id),
          "nat_bvar" = NatBVar(Id),
          Num(i32),
      }
  }
  ```,
) <egglang>

_Rewrite rules._ @rules-data shows the rewrite rules that we use to solve
$udata$. These rules are what `egg` calls multi-rewrites. They allow for
simultaneous searching or application of many terms, while being constrained to
the same substitution. Additionally, the left-hand side is not implicitly set
equal to the right-hand side. Instead, we can decide which terms should be set
equal. We denote this with a different arrow $|->$ as opposed to the arrow $->$
for regular rewrites. The first six rewrite rules are implementing the
unification rules #smallcaps[UD-Decompose-$ast$] shown in @decomp-fine: We
search for unification goals containing each #r("data")type constructor (and the
function type), and unify their components if the constructor matches. The last
rewrite rule corresponds to #smallcaps[U-Eliminate]: Upon seeing a unification
goal with a variable on the left, this variable gets substituted by its solution
in the remaining solution set. In our e-graph, we achieve this by equalizing
both sides of the unification goal. This acts like substituting the variable
because of how we will extract the final substitution from the e-graph later: To
generate the final substitution, we search for each data_mvar contained in the
input unification goals, inspect the e-class it is contained in, and extract a
_canonical_ term as the term that this data_mvar maps to. The canonical term of
an e-class is either the singular concrete #r("data")type constructor or
constant (such as `array` or `f32`) if it exists, or the data_mvar with the
lexicographically smallest name, if a concrete `data`type does not exist. This
effectively maps all data_mvars in one e-class to either the same concrete
`data`type or the same data_mvar, thereby acting as if we had substituted the
data_mvars as it is done in #smallcaps[U-Eliminate]. The rewrite rule also
contains a condition, i.e., it is only applied when this condition is true. The
condition $"if no_conflict"(("data_mvar" pvar(a)),pvar(b))$ prevents creating
conflicts in the spirit of #smallcaps[U-Conflict]. This involves analysis, which
we will cover next.

#figure(
  caption: [Rewrite rules for solving $udata$],
  kind: image,
  placement: top,
  grid(
    columns: 2,
    align: right,
    gutter: 2em,
    $("arrow" pvar(a) med pvar(b)) ~ ("arrow" pvar(c) med pvar(d)) #h(.5em) |-> #h(.5em) #stack(spacing: .5em, $pvar(a) ~ pvar(c)$, $pvar(b) ~ pvar(d)$)$,
    $("arrow" pvar(a) med pvar(b)) ~ ("arrow" pvar(c) med pvar(d)) #h(.5em) |-> #h(.5em) #stack(spacing: .5em, $pvar(a) ~ pvar(c)$, $pvar(b) ~ pvar(d)$)$,
    $("array" pvar(a) med pvar(b)) ~ ("array" pvar(c) med pvar(d)) #h(.5em) |-> #h(.5em) #stack(spacing: .5em, $pvar(a) ~ pvar(c)$, $pvar(b) ~ pvar(d)$)$,
    $("pair" pvar(a) med pvar(b)) ~ ("pair" pvar(c) med pvar(d)) #h(.5em) |-> #h(.5em) #stack(spacing: .5em, $pvar(a) ~ pvar(c)$, $pvar(b) ~ pvar(d)$)$,
    $("vector" pvar(a) med pvar(b)) ~ ("vector" pvar(c) med pvar(d)) #h(.5em) |-> #h(.5em) #stack(spacing: .5em, $pvar(a) ~ pvar(c)$, $pvar(b) ~ pvar(d)$)$,
    $("index" med pvar(a)) ~ ("index" med pvar(c)) #h(.5em) |-> #h(.5em) pvar(a)~pvar(c)$,

    grid.cell(
      colspan: 2,
      align: center,
      $("data_mvar" pvar(a)) ~ pvar(b) |-> ("data_mvar" pvar(a)) = pvar(b) "if no_conflict"(("data_mvar" pvar(a)),pvar(b))$,
    ),
    // q[add \~ commutativity]
  ),
) <rules-data>

_Analysis_. As mentioned before, analysis allows us to attach metadata to each
e-class. The metadata that we use here is related to the canonical term of an
e-class that was mentioned earlier. Namely, we will either store which concrete
type constructor (such as `array` or `f32`) exists in the e-class, or, if none
does, we will store that only data_mvars exist. This information is updated
whenever e-classes are merged. We use this information when attempting to merge
e-classes in the rule discussed earlier. We only merge if there is no _conflict_
between the metadata of the respective e-classes: A conflict constitutes
_differing concrete type information on either side_ of the originating
unification goal. For example, if we have the unification goal
$("data_mvar" pvar(a)) ~ pvar(b)$, and find that the metadata for the e-class of
$("data_mvar" pvar(a))$ is `int` while the metadata for the e-class of $pvar(b)$
is `f32`, we do not merge, since those two types can never be equal. All other
cases are fine to merge, i.e., having the same concrete information on both
sides, or concrete information only on one side, or having metadata indicating
only data_mvars on both sides.

Finally, we need to ensure that both #smallcaps[U-Conflict] and
#smallcaps[U-Check] are enforced. When using e-graphs in practice, it is always
necessary to limit how long to run equality saturation for. Otherwise, it might
not terminate. Fortunately for us, the rules presented in this section are
saturating the e-graph, so we can run them until they would no longer change the
e-graph. After this has been completed, we inspect the resulting e-graph. First,
we inspect every unification node ($~$) that was created during equality
saturation. If for every unification node, both of its edges point to the same
e-class, we know that the unification goal was reached, because both sides have
been made equal by equality saturation. If this is not the case, we declare the
unification as failed as in #smallcaps[U-Conflict]. Additionally, we need to
enforce that there are no cycles pertaining to data_mvars in the e-graph, as in
#smallcaps[U-Check]. This is achieved during extraction: If we need to visit the
e-class of (data_mvar $pvar(a)$) more than once while extracting the
substitution for (data_mvar $pvar(a)$), we know that a cycle exists. Since this
would lead to an infinite term, we abort in this case and declare unification as
failed.

Now that we showed how we solve $udata$ with equality saturation, we move on to
solving $unat$.

=== Solving $unat$ <solve-unat>
When the previously described #r("data")-unifying process is done and
successful, we can consider #r("nat")-unifying. We will be left with a set of
unification goals where both sides are of kind #nat. As before, we attempt to
find a substitution that makes both sides of all unification goals equal.
// maybe?
However, what we desire is not syntactic equality, but rather semantic
equivalence (see #smallcaps[R-NatEquiv] in @rise-tyrules), since #r(
  "nat",
)-unification is a specific kind of E-Unification. For example, given one
unification goal of $bmv(a) ~ nmv(m) - 4$, it will be valid to find the
substitution $[nmv(m)|-> bmv(a)+4]$ which yields semantic equivalence between
both sides, but not syntactic equality.

#figure(
  caption: [First #r("nat")-ruleset: Isolation of metavariables by applying
    properties of equalities],
  kind: image,
  grid(
    columns: 12,
    gutter: 1em,
    column-gutter: 2.5em,
    grid.cell(
      colspan: 12,
      $pvar(c) ~ pvar(a) slash pvar(b) -> pvar(c) dot pvar(b) ~ pvar(a) "if not_zero"(pvar(b))$,
    ),
    grid.cell(
      colspan: 12,
      $pvar(c) ~ pvar(a) dot pvar(b) -> pvar(c) slash pvar(b) ~ pvar(a) "if not_zero"(pvar(b))$,
    ),
    grid.cell(
      colspan: 12,
      $pvar(c) ~ pvar(a) + pvar(b) -> pvar(c) - pvar(b) ~ pvar(a)$,
    ),
    grid.cell(
      colspan: 12,
      $pvar(c) ~ pvar(a) - pvar(b) -> pvar(c) + pvar(b) ~ pvar(a)$,
    ),
    grid.cell(colspan: 4, $pvar(a) ~ pvar(b) -> pvar(b)~pvar(a)$),
    grid.cell(colspan: 4, $pvar(a) + pvar(b) -> pvar(b) + pvar(a)$),
    grid.cell(colspan: 4, $pvar(a) dot pvar(b) -> pvar(b) dot pvar(a)$),
    grid.cell(
      colspan: 12,
      $("nat_mvar" pvar(a)) ~ pvar(b) |-> ("nat_mvar" pvar(a)) = pvar(b)$,
    ),
  ),
) <rules-isol>

We will employ two different rulesets for performance reasons. The first ruleset
is given in @rules-isol. Its purpose is to isolate #r("nat")-metavariables,
i.e., rearrange the unification goals such that we have only a metavariable on
one side, and the term that this metavariable resolves to on the other side. The
first four rules represent applying properties of equalities such as the fact
that we can always add an arbitrary quantity to both sides of an equation.
Effectively, we "move" $pvar(b)$ to the other side of the unification goal.
Whenever division is involved, we need to make sure that we do not divide by
zero. In an e-graph (and when working with symbols), this property is not as
easy to check for as it may seem. We will treat this condition with a more
in-depth analysis in @complete. The next three rules assert commutativity of
unification, addition, and multiplication, which are necessary to isolate all
metavariables; Otherwise, we might move a metavariable into a complex term while
isolating e.g. a constant. With commutativity, the e-graph explores both "moves"
simultaneously. The last rule is reminiscent of the last rule of #r(
  "data",
)-unification (@rules-data). Its purpose is similar: It acts like a substitution
of the respective metavariable. It also makes sure that each metavariable has a
unique final solution in the e-graph, by equalizing it with all solutions that
are found during this isolation process. However, note that we equalize
unconditionally. This may lead to setting terms equal in the e-graph that are
actually impossible to be equal for natural numbers. We will discuss this issue
further in @discus.

We have now established how this first ruleset isolates metavariables. The next
step will be to simplify the solutions that were found, since the resulting
terms may be quite complex. However, during the process of isolation, many
intermediate unification goals are added to the e-graph where metavariables are
not isolated yet. The usually advantageous non-destructive nature of equality
saturation is a disadvantage here: If we were to apply simplification rules to
this e-graph, we would also simplify _all_ intermediate unification goals, even
though we are not interested in them. Not only is that unnecessary work, it is
also highly detrimental to performance: Simplification would take much longer.
Thus, before attempting to simplify the resulting terms, we extract the unique
solution for each metavariable from the current e-graph, and add all solutions
-- along with which metavariable they belong to -- to a new, much smaller
e-graph. This does however also mean that we cannot use the criterion of "For
every unification goal, do both edges point to the same e-class?" that we used
for #r("data")-unification to determine whether conflicts occurred. While it may
lead to discovering unsatisfiability of given unification goals in the e-graph,
it is not viable performance-wise.

#figure(
  // grid(
  //   columns: 2,
  //   // column-gutter: 2em,
  //   row-gutter: 1em,
  //   // add
  $
    pvar(a) + pvar(b) &-> pvar(b) + pvar(a)\ (pvar(a) + pvar(b)) + pvar(c) &-> pvar(a) + (pvar(b) + pvar(c))\
    pvar(a) + 0 &-> pvar(a)\ pvar(a) + (pvar(b) - pvar(c)) &<-> (pvar(a) + pvar(b)) - pvar(c)\
    pvar(a) - (pvar(b) + pvar(c)) &-> pvar(a) - pvar(b) - pvar(c)\ pvar(a) - 0 &-> pvar(a)\
    pvar(a) - pvar(a) &-> 0\ pvar(a) dot pvar(b) &-> pvar(b) dot pvar(a)\
    pvar(a) dot (pvar(b) dot pvar(c)) &-> (pvar(a) dot pvar(b)) dot pvar(c)\ pvar(a) dot 1 &-> pvar(a)\
    pvar(a) dot 0 &-> 0\ pvar(a) dot (pvar(b) + pvar(c)) &-> (pvar(a) dot pvar(b)) + (pvar(a) dot pvar(c))\
    pvar(a) slash 1 &-> pvar(a)\ pvar(a) slash pvar(a) &-> 1 "if not_zero"(pvar(a))\
    pvar(a) dot (pvar(b) slash pvar(a)) &-> pvar(b) "if not_zero"(pvar(a))\
    pvar(a) slash (pvar(b) slash pvar(c)) &-> pvar(a) dot (pvar(c) slash pvar(b)) "if not_zero"(pvar(b), pvar(c))\
    (pvar(a) + pvar(b)) slash pvar(c) &-> (pvar(a) slash pvar(c)) + (pvar(b) slash pvar(c)) "if not_zero"(pvar(b), pvar(c))\
    pvar(a) + (pvar(b) slash pvar(c)) &-> ((pvar(a) dot pvar(c)) + pvar(b)) slash pvar(c) "if not_zero"(pvar(c))\
  $,
  // ),
  caption: [Simplification rules for #r("nat")-unification containing various
    identities of natural numbers.],
) <rules-simp>

After adding the unique solutions of metavariables to a new e-graph, we can
perform simplification on that e-graph and finally extract the simplified
solutions. We define a simplified term as the term with the smallest AST size
among the terms it is equal to. Simplification is done using the second ruleset
shown in @rules-simp. This ruleset includes various identities of natural
numbers such as associativity of addition, distribution of multiplication, and
identity of subtraction. This is also where a second type of analysis comes into
play: constant folding. We annotate each e-class with metadata which states
which constant natural number exists in the e-class, if any. Whenever an
operator points to children which both are constants, we can fold them and add
constant information and a new e-node to its e-class. For example, if a
$+$-e-node points to e-classes with constant information of $2$ and $5$
respectively, we add a $7$-e-node to the e-class of the $+$-e-node, and update
the metadata of that e-class to be $7$ as well. For this ruleset, it is
necessary to declare a limit for when to stop equality saturation. This is due
to rules such as associativity and commutativity growing the e-graph
drastically#footnote[Consider the term $a+b+c+d$. There are 4!=24 different ways
  to order the subterms due to commutativity of addition. Furthermore, there are
  $C_(4-1)=5$ ways to associate the subterms, where $C_n$ is the $n$th Catalan
  number. Hence, having this term in an e-graph along with rewrite rules for
  associativity and commutativity will result in the e-graph representing
  $24 dot 5 = 120$ syntactically different, but semantically equivalent terms.].
Regrettably, this implies that the resulting terms may not be as simplified as
they could be. Hence, we need to strike a balance between runtime performance
and sufficient simplification. We will discuss this balance further in the next
chapter.

Once we have found a solution for each metavariable and simplified the
solutions, we build a substitution mapping each metavariable to its solution,
and apply this substitution to the type of the originating #rise program. Notice
that a crucial step of #r("nat")-unification is still missing, namely that we
have to verify whether after applying the substitution to each unification goal,
semantic equivalence holds for each unification goal. There are multiple reasons
for why this verification is difficult to do with equality saturation, all of
which we will discuss in the next chapter.

// have to verify the found substitution:
// 1. After applying the substitution to the unification goals, semantic
//   equivalence must hold for each unification goal.
// 2. Our #r("nat")-terms are symbolic, i.e., they may contain bound variables of
//   the #rise input program. Thus, we must prove that the unification goals (after
//   applying the substitution) are satisfiable for those bound variables, i.e.,
//   that there #q[]

This concludes the presentation of unification and our approaches to solve it
for the dependent types of #rise, using the MM-Algorithm and SymPy as one
approach, and Equality Saturation as the other. As hinted above, there are
soundness issues with our usage of Equality Saturation. We will discuss these
issues in the next chapter, give possible solutions to them, and discuss other
aspects of our approaches as well, such as runtime performance and
extensibility.
// We do however create new unification goals when applying properties of equalities ...

// cannot use the same process as before...

// #include "egraph.typ"
// === Forward Chaining EqSat
// === Backward Chaining EqSat + SMT
// === SMT / SyGuS (?)

