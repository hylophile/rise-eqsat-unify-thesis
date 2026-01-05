// common definitions
#import "base.typ": *

// lines in code blocks
#import "@preview/zebraw:0.6.1": *
#show: zebraw.with(
  numbering-separator: true,
  numbering-font-args: (fill: black.transparentize(40%)),
  lang: false,
  background-color: black.transparentize(99%),
  inset: (left: 1em),
)

// page header & footer
#import "@preview/hydra:0.6.2": hydra

// #set page(width: 210mm + 100mm, margin: (x: 75mm))
// #set page("a3", flipped: true, columns: 2)

// thin (3/18 em), med (4/18 em), thick (5/18 em), quad (1 em), wide (2 em).

// colored links
#show ref: set text(blue.darken(20%))
#show cite: set text(blue.darken(20%))
#show link: set text(blue.darken(20%))


// block paragraphs
#set par(justify: true)

#set figure(placement: auto, gap: 1em)
// #show figure: set place(clearance: 1em)
#show figure: set place(
  clearance: 2em,
)

#set raw(syntaxes: "rise.sublime-syntax")
// #show raw.where(block: true): set block(
//   inset: .5em,
//   stroke: 1pt + black.lighten(80%),
//   radius: .2em,
//   width: 80%,
// )

// #show list: set block()

// line numbering for feedback
// #set par.line(numbering: "1")
// #set par.line(numbering: n => text(
//   size: .7em,
//   font: "CommitMono",
//   fill: red,
// )[#n])

#show raw: it => {
  set text(font: "JetBrains Mono")
  it
}

#show heading.where(level: 1): set heading(supplement: "Chapter")
#show heading.where(level: 1): it => text(size: 1.25em)[#it]
#show heading.where(level: 1): it => pagebreak(weak: true) + it + v(1em)
#show heading.where(level: 4): it => {
  set text(weight: "regular")
  emph(it.body)
}
#include "preamble.typ"

#set heading(numbering: "1.1")
#set page(header: context {
  if calc.odd(here().page()) {
    grid(
      columns: 2,
      column-gutter: 1fr,
      context counter(page).display(), emph(hydra(1)),
    )
  } else {
    grid(
      columns: 2,
      column-gutter: 1fr,
      emph(hydra(1)), context counter(page).display(),
    )
  }
})

#include "intro.typ"
#include "rise.typ"
// == Syntax
// == Type System

// = Implementing #rise in Lean
// deep vs. shallow, decisions made

// early conclusions about lean and our decisions

// == Typed Rise Expression Data Structure
// == Metavariables
#include "unification.typ"
#include "discussion.typ"
// mention inverse neede to isolate mvars
// == Evaluation: Comparison Table
// === Performance
// === Ease of Use
// === Extensibility
// remove stuff
// === Limitations
// lessons learned. (science community vs. author)
#include "future.typ"
// future work should neither be trivial nor megalomaniac
// == Generating DSLs by Specification

#bibliography(
  "references.bib",
  style: "chicago-author-date",
)
// Well, simplification should matter than, when two syntactical different numerical expressions can be simplified to the same expression but they are not yet. Then we need to perform more simplification to see that they are indeed the same.

// If this does not matter for the RISE expressions you have looked at, you should say so, but you should also explain the above.
#set heading(numbering: "A", supplement: [Appendix])
#counter(heading).update(0)
// #outline(target: heading.where(supplement: [Appendix]), title: [Appendix])
#include "appendix.typ"
