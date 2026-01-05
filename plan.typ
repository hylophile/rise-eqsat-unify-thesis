#import "@preview/diagraph:0.3.6": *
// #set page(width: auto)
= Writing Plan
#raw-render(
  width: 100%,
  ```
  digraph {
    node [shape=box];

    s[label=<Situation>]
    c[label=<Complication>]
    q[label=<Question>]
    a[label=<Answer>]
    v[label=<Value>]
    s->c->q->a->v

    s0[label=<We want to prove <br/>preservation of semantics of Elevate rewrite rules; compiling flow rise via dpia to c; prove correctness>]
    c00[label=<Rise and Elevate are implemented in Scala2 <br/>— updating to Scala3 is difficult<br/>— Scala provides <i>some</i>, but limited, eDSL capabilities<br/>— Scala is not a proof assistant>]

    s0->c00
    c01[label=<Proofs about in /Agda(?) exist,<br/>i.e. the system is fragmented<br/>and there is no single source of truth>]
    s0->c01
    q0[label=<Can we re-implement Rise and Elevate in a proof assistant<br/>and stay reasonably performant (w.r.t. compile time)?>]
    c00->q0
    c01->q0
    a0[label=<Lean>]
    q0->a0
    v0[label=<A single source of truth for implementation,<br/>rewrites, and their proofs of semantics preservation>]
    a0->v0

    s1[label=<see: heterogeneous vs homogeneous equality <br/>clarify role of dependent typing;;; eqsat can use syntactic rewrites to show semantic equalities;;; Dependent types necessitate<br/>manual proofs of equality (during Unification)>]
    s2[label=<Some (e.g. dependently typed, <br/>parametrically polymorphic) languages<br/>need to implement unification>]

    c10[label=<Requires time and effort for users>]
    s1->c10

    c20[label=<Requires time and effort for language developers>]
    s2->c20

    q10[label=<Can we automate these proofs?>]
    c10->q10
    q20[label=<Can we automate <b>ALL OF</b><br/> of unification?>]
    c20->q20

    a10[label=<CAS: SymPy> color=green]
    q10->a10[label=Yes]
    a11[label=<SMT: z3> color=red]
    q10->a11[label=No]
    a12[label=<EqSat: egg>]
    q10->a12[label=<???>]
    q20->a12[label=<Yes>]

    v10[label=<Dependent types become easier to use>]
    a10->v10
    a12->v10
    v20[label=<Implementing languages that use unification<br/>may be partially automated<br/>⇒ part of a larger goal of<br/>"language generation by specification">]
    a12->v20
  }
  ```,
)
#pagebreak()

#set page(paper: "a4")

