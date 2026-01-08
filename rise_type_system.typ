
#import "base.typ": *
== #rise's Type System <rise-type-system>

#let risety = (
  $
    kappa ::= & "type" | "data" | "nat" \
              & #unimp($|$) #unimp(nat2data) #unimp($|$) #unimp(nat2nat) //#unimp($|$) #unimp("addrSpace")
  $,
  ir(
    label: [R-Var],
    ($Delta|Gamma tack theta : "type"$, $x in.not "dom"(Delta union Gamma)$),
    $Delta|Gamma, x:theta tack x : theta$,
  ),
  ir(
    label: [R-Var2],
    (
      // $kappa in {#unimp[addrSpace, nat2nat, nat2data,] "nat", "data"}$,
      $kappa eq.not "type"$,
      $x in.not "dom"(Delta union Gamma)$,
    ),
    $Delta, x : kappa|Gamma tack x : kappa$,
  ),
  [],
  // ir(
  //   label: [R-Weak],
  //   (
  //     $Delta|Gamma tack E: theta_1$,
  //     $Delta|Gamma tack theta_2:"type"$,
  //     $x in.not "dom"(Delta union Gamma)$,
  //   ),
  //   $Delta|Gamma, x : theta_2 tack E: theta_1$,
  // ),
  // ir(
  //   label: [R-Weak2],
  //   (
  //     $Delta|Gamma tack x : kappa_1$,
  //     $kappa_2 eq.not "type"$,
  //     $x in.not "dom"(Delta union Gamma)$,
  //   ),
  //   $Delta|Gamma,y:kappa_2 tack x : kappa_1$,
  // ),
  // ir(
  //   label: [R-TermVar],
  //   ($Gamma tack theta : "type"$, $x in.not "dom"(Gamma)$),
  //   $Delta|Gamma tack x : theta$,
  // ),
  // ir(
  //   label: [R-Gamma],
  //   $x : theta in Gamma$,
  //   $Delta|Gamma tack x : theta$,
  // ),
  // ir(
  //   label: [R-Delta],
  //   $x : kappa in Delta$,
  //   $Delta tack x : kappa$,
  // ),
  ir(
    label: [R-App],
    (
      $Delta|Gamma tack E_1 : theta_1 -> theta_2$,
      $Delta|Gamma tack E_2 : theta_1$,
    ),
    $Delta|Gamma tack E_1 thick E_2 : theta_2$,
  ),
  ir(
    label: [R-App2],
    ($Delta|Gamma tack E : (x : kappa) -> theta$, $Delta tack tau : kappa$),
    $Delta|Gamma tack E thick tau : theta[x mapsto tau]$,
  ),
  ir(
    label: [R-Abst],
    (
      $Delta|Gamma , x : theta_1 tack E : theta_2$,
      $Delta|Gamma tack theta_1 -> theta_2 : "type"$,
    ),
    $Delta|Gamma tack lambda x.E : theta_1 -> theta_2$,
  ),
  ir(
    label: [R-Abst2],
    (
      $Delta, x : kappa|Gamma tack E : theta$,
      $Delta tack (x : kappa) -> theta : "type"$,
      // $x in.not "dom"(Gamma)$,
    ),
    $Delta|Gamma tack Lambda x.E : (x : kappa) -> theta$,
  ),
  grid.cell(ir(
    label: [R-Fun],
    ($Delta tack theta_1 : "type"$, $Delta tack theta_2 : "type"$),
    $Delta tack theta_1 -> theta_2 : "type"$,
  )),
  grid.cell(ir(
    label: [R-Fun2],
    (
      $kappa eq.not "type"$,
      $Delta, x : kappa tack theta : "type"$,
      // $kappa in {#unimp[addrSpace, nat2nat, nat2data,] "nat", "data"}$,
    ),
    $Delta tack (x : kappa) -> theta : "type"$,
  )),
  ir(
    label: [R-TEquiv],
    (
      $Delta|Gamma tack E : theta_1$,
      $Delta tack theta_2 : "type"$,
      $theta_1 equiv theta_2$,
    ),
    $Delta|Gamma tack E : theta_2$,
  ),
)

#let lambdac = (
  grid(
    columns: 1fr, align: horizon,
    gutter: 1.5em,
    $s::=* | square$,
    ir(
      label: [λC-Sort],
      [],
      [$emptyset tack * : square$],
    ),
  ),
  ir(
    label: [λC-Var],
    (
      $Gamma tack A : s$,
      $x in.not "dom"(Gamma)$,
    ),
    $Gamma, x : A tack x : A$,
  ),
  [],
  ir(
    label: [λC-Weak],
    (
      $Gamma tack A : B$,
      $Gamma tack C : s$,
      $x in.not "dom"(Gamma)$,
    ),
    $Gamma, x : C tack A : B$,
  ),
  // [],
  ir(
    label: [λC-App],
    (
      $Gamma tack M : Pi x : A . B$,
      $Gamma tack N : A$,
    ),
    $Gamma tack M thick N : B[x mapsto N]$,
  ),
  [],
  ir(
    label: [λC-Abst],
    (
      $Gamma, x : A tack M : B$,
      $Gamma tack Pi x : A . B : s$,
    ),
    ($Gamma tack lambda x : A . M : Pi x : A . B$),
  ),
  [],
  ir(
    label: [λC-Form],
    (
      $Gamma tack A : s_1$,
      $Gamma, x : A tack B : s_2$,
    ),
    $Gamma tack Pi x : A . B : s_2$,
  ),
  [],
  ir(
    label: [λC-Conv],
    (
      $Gamma tack A : B$,
      $Gamma tack B' : s$,
      $B =_beta B'$,
    ),
    $Gamma tack A : B'$,
  ),
  [],
  [],
  [],
  [],
)

#figure(
  caption: [λC Typing Rules (left) per #cp(<nederpeltTypeTheoryFormal2014>) and
    related #rise Typing Rules (right).],
  grid(
    columns: (5fr, 6fr),
    row-gutter: 1.25em,
    // align: (bottom + center, bottom + right),
    align: (bottom + left, center + bottom),
    grid.vline(x: 1, stroke: .75pt),
    ..(lambdac.zip(risety)).flatten(),
  ),
) <rise-tyrules>

#rise, as most typed functional languages, is based on typed lambda calculus. As
we mentioned, #rise also supports a restricted form of dependent types. A
popular formal system implementing dependent types is λC, otherwise known as the
Calculus of Constructions. As such, we think it is helpful to compare #rise's
type system to λC in order to elucidate similarities and differences, and
specifically in what way the dependent types of #rise are restricted. To that
end, we reproduce the typing rules of λC as defined in #cp(
  <nederpeltTypeTheoryFormal2014>,
) in @rise-tyrules, and show the corresponding #rise typing rules on the right
where applicable. But before we discuss these type systems in detail, we want to
define what a "dependent type" actually is. In fact, λC supports four different
kinds of dependency:
- _terms depending terms_: Generally, dependence refers to function abstraction.
  For example, the term #box[$lambda x : NN thick . thick 1+x$], representing a
  function that increments $x$, depends on the term $x$.
- _terms depending on types_: As an example, the term
  $lambda alpha : *.lambda x:alpha. x$, depending on the type $alpha$,
  represents the polymorphic identity function. This is also known as parametric
  polymorphism.
- _types depending on types_ allow the feature known as "type constructors", for
  example an array constructor that depends on its element type.
- _types depending on terms_ allow terms to occur in types, for example an array
  constructor that depends on a size, given as natural number.

Most programming languages support the first three kinds of dependency but only
few support the fourth, so what _dependent types_ generally refers to is the
fourth dependency, i.e., _term-dependent types_.


Type systems are usually presented as inference rules, as we do here. Each rule
has a name on the left, zero or more premisses above a horizontal line, and one
conclusion below the line. A rule can be read as an implication: If all the
premises are true, then the conclusion is true as well. Most premises and
conclusions are typing judgements. A typing judgement is a statement of the form
$Gamma tack A : B$, which reads "In the context $Gamma$, the expression $A$ has
type $B$". We call the expression being reasoned about, so $A$ in this case, the
_subject_ of the typing judgement. A context, or environment, is a (sometimes
ordered) set of tuples which map variable names to their types. A typing
judgement is only a valid conclusion of the type system if it possible to
construct a proof tree originating from the typing judgement of the program at
the bottom, to "leaf nodes" of the tree, i.e., rules without premisses, at the
top. We call such a type judgement _derivable_ in the type system. Constructing
this proof tree is done by applying the matching rules of the system to every
premise that is not proven yet. We will now explain the necessity of every λC
rule, and show similarities and differences to #rise.

==== #smallcaps[λC-Sort]
is the only rule of λC without a premise, so every proof tree must lead here.
The conclusion states that even in an empty context, we can judge that
$* : square$. This establishes the concept of _sorts_, or _universes_, which
abstracts the notion of terms having a type. Every expression of a language is
of some sort, e.g. _term_ (sort 0) or _type_ (sort 1). Every object of a sort is
contained within an element of the next larger sort, where _term_ is the
smallest sort, and _type_ is the next larger sort. This is familiar from type
ascriptions such as $x:T$, which we read as "The object $x$ of sort 0 is
contained within $T$, which is an element of sort 1" and usually shorten to "The
term $x$ has type $T$". Sorts then allow us to have statements _about_ types,
namely of which _kind_ (sort 2) they are, which we call the next larger sort.
For example, we could state "the type $T$ has kind $*$". Coming back to the rule
in question, it relates $*$ (sort 2) to $square$ (sort 3). If a proof tree were
to attempt to derive $emptyset tack square : square$ or $emptyset tack * : *$,
we would know that the originating expression was not well-typed. #rise does not
have an exact correspondent to this rule, but rather multiple rules.
Additionally, it comes with many builtin types, which λC does not. We will cover
these rules in @rise-builtin. However, we define $kappa$ here, which are the
kinds (sort 2) that #rise uses. The kinds highlighted in #unimp[green] are those
which conceptually exist in #rise, but are not implemented in this work. This is
also where #rise's sorts end: We do not state anything _about_ kinds (in the
sense of them being the subject of a typing judgement), other than that they
exist.

==== #smallcaps[λC-Var]
is used to append variables and their type to the context. The purpose of a
context is to assign a single type to each free variable. Free variables are
those variables which are not bound, i.e., there is no #box[$λ$-] or $Pi$-binder
surrounding them and binding to the same name. In order to append $x:A$ to the
context, $x$ must not already be mapped in $Gamma$, and the judgement
$Gamma tack A : s$ must hold. The symbol $s$ is either $*$ (sort 2) or $square$
(sort 3), so this rule is derivable if $A$ is either a type (sort 1) or a kind
(sort 2), which in turn means that $x$ is either a term (sort 0) or a type (sort
1). #rise expresses this duality as well, but does so by having one rule for
each sort. #smallcaps[R-Var] directly corresponds to the case of $x$ being a
term, in this case of type $theta$ which must have been judged to be of kind
$"type"$. A notable difference is that #rise uses a split context, written
$Delta|Gamma$, which consists of two sets of mappings. $Gamma$ is the typing
context which maps term variables to their type, while $Delta$ is the kinding
context which maps type variables to their kind. Types in $Gamma$ may depend on
type variables in $Delta$, but not the other way around. By abuse of notation we
also require that variables we add to either context are not yet mapped in
either $Delta$ or $Gamma$, to avoid potential confusion about where names are
mapped. #smallcaps[R-Var2] then is responsible for adding type variables to the
kinding context $Delta$. Note that we do not require a judgement about $kappa$
in the premises, because any kind is well-formed by definition. We only require
that $kappa eq.not "type"$. In our implementation, this concretely means that
$x$ is either of kind $"nat"$, or of kind $"data"$. We will explain the various
kinds of #rise later in @rise-builtin.

==== #smallcaps[λC-Weak]
discharges variables in the context that are not necessary for the judgement at
hand. The name stems from the interpretation of a context as list of assumptions
needed to derive a judgement. If the judgement $Gamma tack A : B$ is derivable,
then adding the assumption of $x : C$ to $Gamma$ is a weaker statement, hence
_weakening_ the context. This rule is specifically necessary in λC because the
context is an _ordered_ set. Without it, there would be no way to derive e.g.
$α : ∗, x : α ⊢ α : ∗$. It must be ordered because $Gamma$ contains both term
and type variables, and the types of the term variables may depend on type
variables, which must exist before them in $Gamma$ for those types to be
derivable. In #rise however, neither $Delta$ nor $Gamma$ need to be ordered,
because as mentioned, only elements in $Gamma$ can depend on elements in
$Delta$, not the other way around. Additionally, there are no intra-dependencies
within either $Delta$ or $Gamma$. Hence, $Delta$ and $Gamma$ are ordinary
unordered sets, which is why we do not need the weakening rule. Matching on a
variable in either #rise context such as $Delta, x:kappa|Gamma$ can thus be read
as the mapping $x:kappa$ existing somewhere in $Delta$, while for λC and
$Gamma, x:C$, the mapping must be at the end of $Gamma$.

==== #smallcaps[λC-App]
shows the application of a function to an argument. If $N$ is judged to be of
type $A$, and $M$ to be of type $Pi x:A.B$, we can apply $M$ to $N$. The
notation $Pi x:A.B$ describes the function type where $B$ may depend on $x$.
When there is no dependency, this is usually shortened to $A->B$. In the type of
$M N$, every $x$ needs to be replaced by $N$ using capture-avoiding
substitution, which prevents accidentally binding (capturing) free variables.
This replacement is only necessary when $B$ actually depends on, i.e. uses, $x$,
which is visible in the corresponding #rise rules. These are again split into
two rules, #smallcaps[R-App] and #smallcaps[R-App2]. #smallcaps[R-App] works
strictly on the term level, applying a function $E_1$ from terms to terms to a
term $E_2$. A dependency between the types $theta_1$ and $theta_2$ cannot exist
here, hence the shortened notation $theta_1 -> theta_2$ is used for the type of
$E_1$, and no substitution needs to happen. In turn, #smallcaps[R-App2] is
type-level application. The notation $(x:kappa) -> theta$ is synonymous to
$Pi x:kappa . theta$. An expression $tau$, which is of sort 1, is applied to an
expression $E$ of sort 0, and all occurrences of $x$ in $theta$ are replaced by
$tau$. Additionally, $kappa eq.not "type"$ must hold, which is not given here
explicitly, but rather follows from the well-formedness of $(x:kappa)->theta$,
which we will discuss later. Notice also that $x$ is not an object of an
arbitrary sort as it is in #smallcaps[λC-App], but specifically of sort 1, i.e.,
it is a type. This shows a major restriction in #rise and why it is not a fully
dependently typed language: Types (sort 1) cannot depend on arbitrary terms
(sort 0) like they can in λC, but only on other types (sort 1). However, #rise
offers (among other kinds) expressing natural number values _on the type-level_.
This restriction is by design. It allows precisely those dependent types which
suit its purpose.

// but rather nats are like what we understand as terms or values, but are in
// reality components of a type, but also not a type themselves....


==== #smallcaps[λC-Abst]
implements the eponymous construct of λC: the lambda abstraction. It represents
an anonymous function that binds the parameter $x$ in the body $M$. In order to
construct it, $Gamma, x:A tack M : B$ must be derivable. The ascription $x:A$
must be in $Gamma$ since $x$ may be free in either $M$ or $B$. Additionally,
$Gamma tack Pi x:A.B : s$ must be derivable, where $s$ is again either $*$ or
$square$. So this rule again works on two levels of sorts, and yet again #rise
implements this duality in two different rules #smallcaps[R-Abst] and
#smallcaps[R-Abst2].

Similarly, #emph(smallcaps[λC-Form]) implements the function type, which #rise
splits into term-level and type-level as before.


==== #smallcaps[λC-Conv]
admits identification of two types $B$ and $B'$ if they are $beta$-equivalent,
i.e., either $B$ $beta$-reduces in $n>=0$ steps to $B'$ or vice versa. Without
going into too much technical detail, $beta$-reduction intuitively mimics
calculation by applying arguments to lambda functions. It is necessary to
identify types such as $(λ α : ∗. α →α) β$ and $β→β$. Since #rise does not allow
arbitrary abstractions in types, it does not need to consider
$beta$-equivalence. Instead, for two types $theta_1$ and $theta_2$ to be
identifiable, they need to be _semantically equivalent_,
$theta_1 equiv theta_2$. Determining this semantic equivalence is particularly
interesting for natural numbers, i.e., #rise's $"nat"$ kind, which we will see
later. Apart from their $"nat"$ components, two types are semantically
equivalent iff the other components are $alpha$-equivalent, i.e., only binding
variables need to be renamed for them to be syntactically equivalent. Do note
that this ignores applied type-level functions (see below), but since we did not
implement them, we do not focus on them here.

#figure(
  caption: [Built-in types and kinds of #rise.],
  $
    kappa &::= "type" | "data" | "nat" #unimp($|$) #unimp(nat2data) #unimp($|$) #unimp(nat2nat) //#unimp($|$) #unimp("addrSpace")
    \
    zeta &::= "natType" | "bool" | "int" | "i8" | "i16" | "i32" | "i64" | "u8" | "u16" | "u32" | "u64" | &"f16" | "f32" | "f64" \
    // #unimp($alpha$) &#unimp($::= "global" | "local" | "private" | "constant"$)
  $
    + grid(
      columns: (1fr,) * 6,
      row-gutter: 1em,
      // stroke:red,
      align: bottom + center,
      grid.cell(colspan: 2, ir(
        label: [R-NatLit],
        $$,
        $Delta tack underline(ell) : "nat"$,
      )),
      grid.cell(colspan: 4, ir(
        label: [R-NatOp],
        (
          $Delta tack N : "nat"$,
          $Delta tack M : "nat"$,
          $plus.o in {*,slash,+,-,#unimp($dots$)}$,
        ),
        $Delta tack N plus.o M : "nat"$,
      )),
      grid.cell(colspan: 6, ir(
        label: [R-NatEquiv],
        $forall sigma : op("dom")(Delta) -> NN thick . thick sigma(N) = sigma(M)$,
        $N equiv M$,
      )),
      // grid.cell(colspan: 6, unimp(ir(
      //   label: [R-AddrSpace],
      //   $$,
      //   $Delta tack alpha : "addrSpace"$,
      // ))),
      grid.cell(colspan: 3, unimp(ir(
        label: [R-Nat2Nat],
        $Delta, n : "nat" tack M : "nat"$,
        $Delta tack n mapsto M : nat2nat$,
      ))),
      grid.cell(colspan: 3, unimp(ir(
        label: [R-Nat2Data],
        $Delta, n : "nat" tack T : "data"$,
        $Delta tack n mapsto T : nat2data$,
      ))),
      grid.cell(colspan: 6, unimp(ir(
        label: [R-Nat2NatApp],
        ($Delta tack F_N : nat2nat$, $Delta tack M : "nat"$),
        $Delta tack F_N M : "nat"$,
      ))),
      grid.cell(colspan: 6, unimp(ir(
        label: [R-Nat2DataApp],
        ($Delta tack F_T : nat2data$, $Delta tack N : "nat"$),
        $Delta tack F_T N : "data"$,
      ))),
      // grid.cell(colspan: 6, []),
      grid.cell(colspan: 6, ir(
        label: [R-Scalar],
        $$,
        $Delta tack zeta : "data"$,
      )),
      // grid.cell(colspan: 2, ir(
      //   label: [R-NatType],
      //   $$,
      //   $Delta tack "natType" : "data"$,
      // )),
      grid.cell(colspan: 3, ir(
        label: [R-Array],
        ($Delta tack N : "nat"$, $Delta tack T : "data"$),
        $Delta tack N_circ T : "data"$,
      )),
      grid.cell(colspan: 3, ir(
        label: [R-Vector],
        ($Delta tack N : "nat"$, $Delta tack zeta : "data"$),
        $Delta tack "vec"[zeta,N] : "data"$,
      )),
      grid.cell(colspan: 3, ir(
        label: [R-Index],
        $Delta tack N : "nat"$,
        $Delta tack "idx"[N] : "data"$,
      )),
      grid.cell(colspan: 3, ir(
        label: [R-Product],
        ($Delta tack T : "data"$, $Delta tack U : "data"$),
        $Delta tack (T,U) : "data"$,
      )),
      grid.cell(colspan: 3, unimp(ir(
        label: [R-DepPair],
        ($Delta, n : "nat" tack T : "data"$),
        $Delta tack (n : "nat" ** T) : "data"$,
      ))),
      grid.cell(colspan: 3, unimp(ir(
        label: [R-DepArray],
        ($Delta tack N : "nat"$, $Delta tack F_T : nat2data$),
        $Delta tack N_(circ circ) F_T : "data"$,
      ))),
      // grid.cell(colspan: 6, []),
      // grid.cell(colspan: 3, ir(
      //   label: [R-Fun],
      //   ($Delta tack theta_1 : "type"$, $Delta tack theta_2 : "type"$),
      //   $Delta tack theta_1 -> theta_2 : "type"$,
      // )),
      // grid.cell(colspan: 6, ir(
      //   label: [R-DepFun],
      //   (
      //     $Delta, x : kappa tack theta : "type"$,
      //     // $kappa in {#unimp[addrSpace, nat2nat, nat2data,] "nat", "data"}$,
      //     $kappa eq.not "type"$,
      //   ),
      //   $Delta tack (x : kappa) -> theta : "type"$,
      // )),
      grid.cell(colspan: 2, ir(
        label: [R-Type],
        $Delta tack T : "data"$,
        $Delta tack T : "type"$,
      )),
      grid.cell(colspan: 2, ir(
        label: [R-Contexts],
        ($Delta tack T : kappa$, $"ftv"(Gamma) subset.eq "dom"(Delta)$),
        $Delta|Gamma tack T : kappa$,
      )),
      grid.cell(colspan: 2, ir(
        label: [R-Prim],
        ($(p : theta) in "Primitives"$, $Delta tack theta : "type"$),
        $Delta tack p : theta$,
      )),
      // grid.cell(colspan: 2, [wtf]),
      // grid.cell(colspan: 2, [wtf]),
      // grid.cell(colspan: 2, [wtf]),
    ),
) <rise-builtin>

Now that we showed #rise's similarities and differences to λC, we will discuss
#rise's built-in types and kinds in more detail (@rise-builtin). As before,
rules highlighted in #unimp[green] exist in #rise, but not in our
implementation. We repeat the definition of $kappa$, which are the kinds that
exist in #rise:
- $"nat"$ is the kind of natural numbers on the type level.
- $"data"$ is used for _data_#h(0em)types, so types which have concrete values
  as their terms.
- $"type"$ groups datatypes and function types. Only datatypes can be "lifted"
  to types (see #smallcaps[R-Type]), so whenever we encounter an expression of
  kind type, we know it must be either data or a function type (see
  #smallcaps[R-Fun] and #smallcaps[R-Fun2] from @rise-tyrules).
- #unimp(nat2data) and #unimp(nat2nat) are type-level functions. We will not
  discuss these further, but want to highlight that this again shows #rise's
  purpose-driven use of dependent types: Only very explicit forms of type-level
  functions are allowed.

Next we have $zeta$, which defines all valid scalar types such as integers,
unsigned integers, and floating point numbers. One notable scalar type is
$"natType"$ which is used to shift a natural number from the type level to the
term level and vice versa.

The three rules pertaining to nats admit literals (#smallcaps[R-NatLit]),
operations on nats (#smallcaps[R-NatOp]), and define semantic equivalence of
nats. #smallcaps[R-NatEquiv] states that in order for $N$ and $M$ to be
semantically equivalent, every substitution $sigma$ must yield the same constant
for both $sigma(N)$ and $sigma(M)$. The substitution replaces all variables in
$N$ and $M$ with constant natural numbers. The intent of the universal
quantification is that $sigma(N)=sigma(M)$ could be "accidentally" true for a
single substitution, e.g. for $N=0$, $M=x$, and $sigma(x)=0$. Requiring the
equality for all substitutions entails that natural numbers will _mean_ the same
thing, i.e., evaluate to the same result in all possible contexts. Note that we
reproduce #smallcaps[R-NatEquiv] here as it is defined by the #rise
authors#footnote[#link(
  "https://rise-lang.org/doc/language-reference/rise-types#type-equality",
)], but we think that the definition is flawed. We will nevertheless use the
definition of semantic equivalence as is for now, and explain why we think it is
flawed in @complete.

// Computing all possible contexts is of course not possible, so this will have to
// be implemented differently.
// In fact, determining semantic equivalence is the central challenge of this
// thesis, and as such will be given careful treatment in @unif.

Skipping the rules relating to type-level functions, we now arrive at #rise's
built-in datatypes. Unsurprisingly, all scalar types $zeta$ are of kind
$"data"$. #smallcaps[R-Array] shows #rise's array type which stores its length
in the type. Since it only requires the element type $T$ to be of kind $"data"$,
this type can also represent multidimensional matrices etc. This is in
opposition to the vector type, which only admits scalars as its element type.
The index type $"idx["N"]"$ restricts its values to range from $0$ to $N-1$
inclusively and is used to index into arrays. Lastly, the product type admits
(nested) tuples. #unimp(smallcaps[R-DepPair]) is used to express data structures
tagged with their size, where the size is potentially computed at runtime.
#unimp(smallcaps[R-DepArray]) expresses positional dependent arrays, where the
element type depends on the position within the array
@pizzutiGeneratingHighPerformance2021. As we did not implement these two
structures, we do not go into further detail here. #smallcaps[R-Contexts] is a
technicality which allows us to relate rules judging only about the type-level
to rules judging about the term-level: Every judgement we can make about types,
i.e., using $Delta$, is also valid for an arbitrary $Gamma$, provided it uses
only those type variables that exist in $Delta$. Last but not least,
#smallcaps[R-Prim] allows us to judge about #rise's primitives.

The avid reader might have noticed that the type system of #rise does not
mention implicit parameters at all. The reason is that they do not add any
expressive power to the type system. Any implicit parameter could just as well
be an explicit parameter without changing the meaning of a program. They instead
serve as a great convenience to the user, allowing them to write much more
concise programs. This leads to more implementation work for type inference,
which we will look at next.
