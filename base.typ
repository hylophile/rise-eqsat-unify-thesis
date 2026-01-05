#import "@preview/curryst:0.5.1": prooftree, rule

#let q(t) = (
  h(.5em) + box(stroke: red + 1pt, outset: 2pt)[#text(fill: red)[#t]] + h(.5em)
)
#let c(t) = text(fill: blue)[#t]

#let cp(l) = cite(form: "prose", l)

#let circ = $circle.filled.small$

#let elevate = {
  set text(font: "Fira Sans")
  upper[Elevʌte]
}

#let rise = {
  set text(font: "Roboto")
  set text(weight: 400)
  [R]
  set text(weight: 500)
  [I]
  set text(weight: 600)
  [S]
  set text(weight: 700)
  [E]
}

#let codeblock(
  c,
) = box(
  c,
  outset: (y: .3em),
  inset: (x: .3em),
  radius: .15em,
  width: 50%,
  // baseline: .2em,
  // fill: oklch(96.8%, 0.007 ,247.896deg),//rgb("#dde"),
  // fill: oklch(86.9%,0.022,252.894deg),
  fill: oklch(92.9%, 0.013, 255.508deg).transparentize(50%),
)

#let ir(label: none, name: none, premise, clusion, ..args) = context {
  let res(..ps) = prooftree(
    stroke: 0.4pt + text.fill,
    rule(
      label: [#smallcaps(label)],
      name: [#name],
      clusion,
      ..ps,
    ),
    ..args,
  )

  if type(premise) == array {
    res(..premise)
  } else {
    res(premise)
  }
}

#let r(c) = box(
  raw(
    lang: "rise",
    c,
  ),
)

#let data = r("data")
#let nat = r("nat")
#let uni = $≐$
#let uni = $tilde$
// #let eqd = $attach(t:".",eq)$
// #let eqd = $limits(=)^"E"$
#let ue = $attach(t: arrow, tilde)$
#let us = $attach(t: plus, tilde)$
#let udata = $attach(tr: D, tilde)$
// #let ue = $tilde$
#let unat = $attach(tr: NN, tilde)$

#let cg(x) = text(fill: blue.darken(30%), $#x$)
// #let meta(x) = $#h(.5em)?#h(0em)#x#h(.5em)$
// #let meta(x) = $#h(.25em)?#h(0em)#x#h(.25em)$
#let pvar(x) = $\$#x$
#let meta(x) = $#h(.25em, weak: true)?#h(0em)#x$
// #let meta(x) = $#h(.25em, weak: false)?#h(0em)#x#h(.25em, weak: false)$
#let metat(x) = $?#h(0em)#x$
#let nmv(x) = $#h(.25em, weak: true)?#h(0em)#x$
// #let nmvt(x) = $?#h(0em)#x$
// #let bmv(x) = $#h(.25em, weak: true)#h(0em)#x#h(.25em, weak: true)$
#let bmv(x) = $#x$
#let bound(x) = $accent(#x, circle)$
#let opr = $plus.o$
#let mvars(x) = $cal(M)(#x)$

#let mono(s) = {
  box(raw(s))
}

#let diagram-conf = (
  // debug: true,
  spacing: 10mm,
  node-corner-radius: 5pt,
  node-stroke: black + .75pt,
  node-shape: "rect",
  node-fill: white,
  // edge-corner-radius: 5pt,
)
#let eclass-conf = (stroke: none, fill: blue.lighten(85%), inset: 5pt)
#let enode-conf = (width: 10mm, height: 10mm, stroke: black.lighten(50%))
#let enode-wide-conf = (width: 20mm, height: 10mm, stroke: black.lighten(50%))
#let edge-conf = (stroke: black.lighten(50%))
#let edge-mark = "-solid"
#let enode-text(s) = text(black.lighten(50%), s)
#let enode-text-hl(s) = text(black, s)

#let eclass-conf-hl = (..eclass-conf, fill: blue.lighten(65%))
#let enode-conf-hl = (..enode-conf, stroke: black)
#let enode-wide-conf-hl = (..enode-wide-conf, stroke: black)
#let edge-conf-hl = (..edge-conf, stroke: black)

#let lshift = (shift: (-0.125, 0))
#let rshift = (shift: (0.125, 0))


#let nat2nat = $"nat"#h(0em)->#h(0em)"nat"$
#let nat2data = $"nat"#h(0em)->#h(0em)"data"$
#let unimp(x) = {
  text(fill: green.darken(20%), x)
}
