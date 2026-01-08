#import "base.typ": *
= Conclusion & Future Work <future>
In this work, we implemented #rise as an embedded domain-specific language in
Lean. We presented #rise's syntax and type system, and highlighted relevant
aspects of our implementation.

Additionally, we explored using Equality Saturation (EqSat) for a crucial part
of type checking and inference: unification. While EqSat is highly extensible,
and as such was able to perform first-order syntactic unification as well as
equational unification, it struggled with runtime performance and soundness.
Namely, the runtime of algebraic simplification is too slow to realistically be
used in #rise's type system, and detecting unsatisfiability in a set of
unification goals raised many issues that we were not able to solve. Because of
these issues, we presented an alternative solution to perform equational
unification for #rise, namely SymPy. #rise's needs to unify terms of natural
numbers containing variables were precisely met by SymPy's ability to solve
systems of equations. However, while SymPy does detect unsatisfiability (with
the caveat of not being proven correct), it does not offer production of an
unsatisfiable core of the system in question, making it difficult to explain to
the user why a specific program did not typecheck.

We identified the need to express constraints in #rise programs. Consider the
program #r("fun a b : nat => fun xs : b·f32 => take (a : nat) xs"). The program
attempts to take `a` elements from an array that is `b` elements long. In
#rise's current type system, this program typechecks, implying that it is valid
for all `a` and `b`. However, this ignores that $#mono("a")>=#mono("b")$ must
hold for this program to not crash at runtime. There are other constraints we
would need to express, such as the fact that when reshaping an array of type #r(
  "a·f32",
) into a matrix of type #r("b·c·f32"), it must hold that
$#mono("a")=mono("b")dot mono("c")$, and that #r("a") is divisible by both #r(
  "b",
) and #r("c") without a remainder. In the future, we want to explore adding
explicit constraints to #rise's type system, and find methods that take these
into account, since both SymPy and EqSat seem unsuitable for this. Ideally,
constraints could be synthesized by such a method and reported back to the user
(as in "This program does not typecheck unless the constraint
$#mono("a")>=#mono("b")$ is added"), who would then add the constraint to the
#rise program. This would achieve stronger guarantees over which #rise programs
are safe (i.e., do not crash with invalid inputs) for which inputs, which
ultimately is one of the goals of a type system.

One method that addresses multiple shortcomings of EqSat and SymPy regarding
equational unification over natural numbers is using an SMT solver.
Specifically, these _automatic theorem provers_ can verifiably guarantee the
(un)satisfiability of a given #r("nat")-unification substitution. Also, they can
produce a minimal set of unsatisfiable unification goals (unsatisfiable core),
giving us a way to explain to the user why their program did not typecheck. And
last but not least, SMT solvers are able to handle constraints over integers, so
they would be suitable for extending #rise with constraints. However, we cannot
use an SMT solver for _producing_ a valid unification substitution since that
requires symbolic computation. In other words, solutions may still depend on
unknown variables (bound variables of the #rise input program), but an SMT
solver finds a satisfiable assignment of _all_ variables of their input, so it
cannot express solutions depending on unknowns. Thus, a potential way forward is
to use EqSat for synthesis, i.e., production of a unification substitution, and
an SMT solver for verification, explainability, and constraints. However, this
would still not perform arithmetic simplification, which we need for a practical
solution.

Assuming that #rise's type system stays as it is, i.e., does not add
constraints, we think that the approach of MM-Algorithm + SymPy (or any other
Computer Algebra System) is the most practical solution, since it covers finding
unsatisfiability (although not proven), performs arithmetic simplification, is
performant enough, and does not need to be extensible. This is under the
condition that we would need to implement the production of an unsatisfiable
core for helpful user feedback. However, tying this back to our motivation of
creating a modular unification engine as part of a language framework, a static
algorithm combined with a CAS is clearly not suitable, which is why we employed
EqSat. While we did face challenges specifically with equational unification of
natural numbers, we found that EqSat is fully capable of first-order syntactic
unification. In the future, we intend to explore whether it may support the type
checking process in other ways, or help with other parts of a language framework
such as execution semantics. Additionally, there are existing projects and
ongoing research around extensions to E-Graphs and symbolic computation that we
want to explore for our purposes:
- P-Graphs#footnote(link("https://pavpanchekha.com/blog/p-graphs.html")): We are
  not the first to realize that E-Graphs struggle with algebraic simplification.
  P-Graphs are a (currently hypothetical) extension to E-Graphs that have
  built-in reasoning about polynomials, so sums and products, which could help
  make the runtime performance of algebraic simplification reasonable.
- Syntax-Guided Synthesis: This is a technique related to SMT solving in that it
  is also formally verified, but focusses on program synthesis
  @alurSyntaxguidedSynthesis2013. This allows it to perform symbolic computation
  since a solution depending on unknown variables can be viewed as a function
  taking those unknown variables as parameters.
- `egglog` is a programming language that combines ideas from EqSat and Datalog,
  a database query language. It shows large speedup running `egg`'s `math` test
  suite @zhangBetterTogetherUnifying2023 compared to `egg`, which could
  potentially be fast enough for our purposes.

