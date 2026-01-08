#import "base.typ": *
= Introduction

#quote(
  block: true,
  [_With dependent types, we can express our _understanding_, not just our
    _procedure_. That is the very purpose of declarative programming – to make
    it more likely that we mean what we say by improving our ability to say what
    we mean._],
  attribution: [#cite(
    <mcbrideFirstorderUnificationStructural2003>,
    form: "prose",
  )],
)

The domain specific language that we implemented in this work is #rise. Although
#rise is only one intermediate representation (IR) in a compiler framework
consisting of multiple IRs @steuwerRISEShineLanguageOriented2022, we will
consider it in isolation here. Nevertheless, it is worth noting that its
existence is motivated by the increasing specialization of software and hardware
due to the end of Moore's Law @luckeIntegratingFunctionalPatternbased2021. Its
goal is to be a high-level data-parallel functional language with an expressive
type system that allows programmers to write declarative programs specialized
towards the intended hardware.

For #rise programs to be optimized and lowered to other IRs, their types need to
be checked and inferred. This is particularly challenging because #rise offers a
restricted form of dependent types, i.e., types may contain values. The
challenge arises when terms of such dependent types are transformed, combined,
split up etc. For example, the type of a matrix in #rise describes not only its
element type, but also the length of each dimension. For two matrices to be
multiplied together, the number of columns in the left matrix must be equal to
the number of rows in the right matrix. Determining this equality when those
numbers are constants is trivial, but becomes a challenge when arbitrarily
complex terms, possibly including unknown variables, are allowed. And this is
not the only equality we have to consider. In fact, every time a function is
applied to an argument, the argument type must be equal to the type of the first
parameter of the function. Conventional systems using dependent types, usually
proof assistants, allow users to provide a proof of equality between two types
if the type checker cannot determine equality automatically. In #rise, we aspire
to fully automate this process. This is only feasible because #rise is not a
fully dependently typed language, but restricts the values that may occur in
types largely to natural numbers. The process of determining whether all
equalities in a given equational system are true (or rather, whether they can be
made true by a substitution, as we will see later) is called unification, the
central part of type checking and type inference of #rise programs that we will
explore. Concretely, we will present two different approaches to solve
unification: First, using SymPy, which is a Computer Algebra System that allows
us to solve the subproblem of unifying natural numbers. Then, Equality
Saturation (EqSat), which is a process based on non-destructive rewrites that is
commonly used for program optimization and equational reasoning. Notably, EqSat
is highly extensible, which allows us to implement every kind of unification
that #rise needs.

The motivation for this work is twofold: \
First, while we could have explored the topic of unification using EqSat just as
well in a minimally viable language, we specifically implemented #rise in the
interactive proof assistant Lean. The current implementation#footnote(
  link("https://rise-lang.org/"),
) uses Scala, which does not support proofs. Having the compiler implemented in
a language that supports proofs will serve as a single source of truth and
greatly simplify proving properties of #rise and its related IRs in the future,
for example whether transformations between IRs are semantics-preserving. We do
not prove anything in this work, but enable future work in this direction by
implementing #rise in Lean.\ Second, we are interested in language generation by
specification in the spirit of SpecTec @younBringingWebAssemblyStandard2024, PLT
Redex @kleinRunYourResearch2012, or K @rosuOverviewSemanticFramework2010,
otherwise known as language frameworks. This can be understood as a system that
receives a declarative specification of a language in the form of its syntax,
type system, and execution semantics, and outputs among other things an
implementation of the language, while crucially being able to detect errors in
the specification. We believe that EqSat has the potential to be part of the
implementation of such a system, particularly because all of the mentioned
systems, just as EqSat, are based on rewrites. This belief is the reason we
employed EqSat for unification, even though unification is merely a small part
of a language framework. Thus, we will also evaluate EqSat with regard to this
aspect, i.e., its feasibility as a modular, extensible unification engine.

In @rise, we will present #rise's features, type system, and relevant parts of
our implementation. @unif will show how we implemented unification with SymPy
and EqSat, respectively. @discus discusses our results and compares both
approaches with regard to attributes that are relevant for a type checker.
Finally, @future will look at extensions that we think #rise could benefit from,
and consider alternative unification implementations.



