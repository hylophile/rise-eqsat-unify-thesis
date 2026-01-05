#import "base.typ": *

==== Standard Unification

#let uni = $≐$
#let uni = $tilde.dot$
// #let eqd = $attach(t:".",eq)$
// #let eqd = $limits(=)^"E"$
#let ue = $attach(t:arrow,tilde)$
#let us = $attach(t:plus,tilde)$

$
  G union { t uni t } &=> G &&#emph[delete] \
  G union { f(s_0,dots,s_k) uni f(t_0,dots,t_k) } &=> G union {s_0 uni t_0,dots,s_k uni t_k} quad quad &&#emph[decompose] \
  G union { f(s_0,dots,s_k) uni g(t_0,dots,t_m) } &=> bot & #text[if $f eq.not g or k eq.not m$] quad quad &#emph[conflict] \
  G union { f(s_0,dots,s_k) uni x} &=> G union { x uni f(s_0,dots,s_k) } &&#emph[swap] \
  G union { x uni t } &=> G[t slash x] union {x uni t} & #text[if $x in.not "vars"(t) and x in "vars"(G)$] quad quad &#emph[eliminate] \
  G union { x uni f(s_0,dots,s_k) } &=> bot & #text[if $x in "vars"(f(s_0,dots,s_k))$] quad quad&#emph[check]
$

#let cg(x) = text(fill: blue.darken(30%), $#x$)
#let meta(x) = $accent(#x,hat)$
#let bound(x) = $accent(#x,circle)$
#let opr = $plus.o$


==== Our Unification
We write $ue$ for unification by EQSat, and $us$ for unification by SMT/CAS.

We use $t, u, v, w$ for types, and $n, m$ for natural number terms.

We use $t(s_0,...,s_k)$ for unspecified datatype constructors with $k+1$ parameters.

We use $meta(x)$ for metavariables and $bound(y)$ for bound variables.

one unify symbol per kind

$
  { t() ue t() } union G &=> G & quad &&#emph[delete] \
  { t(dots) ue u(dots) } union G &=> bot & & #text[if $t eq.not u$] &#emph[conflict] \
  cg({ t -> u ue v -> w } union G &=> G union {t ue v, u ue w } & &&#emph[decompose-fun]) \
  cg({ (t, u) ue (v, w) } union G &=> G union {t ue v, u ue w } & &&#emph[decompose-product]) \
  cg({ "idx"[n] ue "idx"[m] } union G &=> G union {n us m} & &&#emph[decompose-index]) \
  cg({ "vec"[t,n] ue "vec"[u,m] } union G &=> G union {t ue u, n us m} & &&#emph[decompose-vector]) \
  cg({ n_circ t ue m_circ u } union G &=> G union {n us m, t ue u} & &&#emph[decompose-array]) \
  cg(dots&dots&dots&dots&dots) \
  { t(s_0,dots,s_k) ue meta(x)} union G &=> G union { meta(x) ue t(s_0,dots,s_k) } & &&#emph[swap-datatype] \
  { meta(x) ue t } union G &=> G[t slash meta(x)] union {meta(x) ue t} & & #text[if $meta(x) in.not "mvars"(t) and meta(x) in "mvars"(G)$] &#emph[eliminate] \
  { meta(x) ue t(s_0,dots,s_k) } union G &=> bot & & #text[if $meta(x) in "mvars"(t(s_0,dots,s_k))$] quad quad&#emph[check] \
  cg({ n us meta(x) } union G &=> G union {meta(x) us n} & &&#emph[swap-nat]) \
  cg({ n us m } union G &=> G[p slash meta(x)] union {meta(x) us p} & & #box(text[if $meta(x) in "mvars"(n) union "mvars"(m) and meta(x) in.not "mvars"(p)$\ with $p := "solve"(n=m) "for" meta(x)$]) &#emph[solve-mvar]) \
  // cg({ meta(x) opr m us n } union G &=> G union {meta(x) us n opr^(-1) m } & &&#emph[simplify-mvar-1]) \
  // cg({ n us meta(x) opr m } union G &=> G union {meta(x) us n opr^(-1) m } & &&#emph[simplify-mvar-2]) \
  // cg({ meta(x) opr m us bound(y) opr n } union G &=> G union {meta(x) us (bound(y) opr n) opr^(-1) m } & &&#emph[solve-mvar *(unnecessary?)*]) \
  cg({ meta(x) us n } union G &=> G[n slash meta(x)] union {meta(x) us n} & & #text[if $meta(x) in.not "mvars"(n) and meta(x) in "mvars"(G)$] &#emph[eliminate-nat]) \
  cg({ meta(x) us n } union G &=> bot & & #text[if $meta(x) in "mvars"(n)$] quad quad&#emph[check-nat]) \
$

// #pagebreak()
// #pagebreak()
// #let qu = $op("?")$
// #set text(size: 20pt)
// $&NN = {1,2,...}
// \
//  &qu p * 4 = n
// \
//  &=> "solve for " qu p "in terms of n"
// \
// &=> qu p = n / 4 quad and quad n "mod" 4 =0
// \
// \
// // &n > 4 => qu p = n-4
// &"how do we check whether the solution is unique?"
// \
// &"put all constants in the grammar (4 and 0 here)"
// // &"(E & p = n/4) => p >=0"
// \
// // &(exists qu p. ?p = n/4) => p >=0
// \

// &"(Sidecondition &  p x = x/4) => p>=0"
// \
// &$$
// \
// // &?p + ?q = 4
// $
// #pagebreak()
// #set text(size: 10pt)

== notes

- hello
-

- we *have* to set things equal, no matter the technique
- constant propagation = death of the universe

#v(1cm)

// #grid(
//   columns: 2, gutter: 1.5em,
//   // grid.cell(
//   //   colspan: 2,
//   //   ir(
//   //     $G union {n us X}$,
//   //     $G union {X us n} & &&$,
//   //     label: [swap-nat],
//   //   ),
//   // ),
//   // grid.cell(
//   //   colspan: 2,
//   //   ir(
//   //     ($G union {n us m}$, ),
//   //     $G[X |-> p] union { X us p | X in "metavariables"(n) union "metavariables"(m), p:=}$,
//   //     label: [UN-Isolate],
//   //   ),
//   // ),
//   // grid.cell(
//   //   colspan: 2,
//   //   ir(
//   //     ($G union {n plus.o m us p}$, $"metavariable" in n$, $plus.o in {+,-,slash,ast,\^}$),
//   //     $G union {n us p plus.o^(-1) m}$,
//   //     label: [UN-Solve],
//   //   ),
//   // ),
//   grid.cell(
//     colspan: 2,
//     ir(
// ($G union {X us n, X us m} & &&$, $n eq.not m$),
//       $bot$,
//       label: [UN-Conflict],
//     ),
//   ),
//   grid.cell(
//     colspan: 2,
//     ir(
// ($G union {n us m} & &&$, $n eq.not m$),
//       $bot$,
//       label: [UN-Conflict2],
//     ),
//   ),
//   [],[],
//   grid.cell(
//     colspan: 2,
//     ir(
//       (
//         $G union {n us m}$,
//         $X in metavariables(n) union metavariables(m) and X in.not metavariables(p)$,
//         $p := "solve"(n=m) "for" X$,
//       ),
//       $G[X |-> p] union {X us p}$,
//       label: [solve-metavariable],
//     ),
//   ),
//   // grid.cell(
//   //   colspan: 2,
//   //   ir(
//   //     $G union {X us n}$,
//   //     $G[n slash X] union {X us n} & & #text[if $X in.not "metavariables"(n) and X in "metavariables"(G)$] &$,
//   //     label: [eliminate-nat],
//   //   ),
//   // ),
//   grid.cell(
//     colspan: 2,
//     ir(
//       (
//         $G union {X us n}$,
//         $X in metavariables(n)$,
//         $X eq.not n$
//       ),
//       $bot$,
//       label: [check-nat],
//     ),
//   ),
// )

#let multirw(
  inp,
  out1,
  out2,
) = diagram(
  node(
    (0, 0),
    (inp),
    name: <f>,
  ),
  node((.85, -.2), (out1), width: 1.5cm, name: <t1>),
  node((.85, .2), (out2), width: 1.5cm, name: <t2>),
  edge(<f.east>, (rel: (.05, 0)), <t1.west>, "|->"),
  edge(<f.east>, (rel: (.05, 0)), <t2.west>, "|->"),
)
