#import "base.typ": *


#let details = toml("details.toml")

#let title = [Type Checking a Dependently Typed DSL Supported by Equality
  Saturation]

#grid(
  align: center, gutter: 1fr, columns: 1fr,
  scale(180%, image("tu-berlin-logo-long-red.svg")),
  text(size: 2em)[*Masterarbeit*],
  text(size: 1.5em)[*#title*],
  text(
    size: 1.25em,
    {
      show table.cell: it => {
        if it.x == 1 {
          set align(left)
          emph(it)
        } else {
          set align(right)
          it
        }
      }
      table(
        columns: 2,
        stroke: none,
        column-gutter: 1em,
        row-gutter: .5em,
        [vorgelegt von], [#details.name],
        [Matrikelnummer], [404134],
        [eingereicht am], datetime.today().display(),
        [Betreuer], [Prof. Dr. Michel Steuwer],
        [Erstprüfer], [Prof. Dr. Michel Steuwer],
        [Zweitprüfer], [Prof. Dr. Andrés Goens],
      )
    },
  )
  ,

  [Fachgebiet Programmiersprachen\ Institut für Softwaretechnik und Theoretische
    Informatik\ Technische Universität Berlin]
)

#pagebreak()

#heading(outlined: false)[Eidesstattliche Erklärung]

Hiermit versichere ich, #details.name, an Eides statt, dass ich die vorliegende
Masterarbeit mit dem Titel _ #title _ selbständig und ohne fremde Hilfe verfasst
und keine anderen als die angegebenen Hilfsmittel benutzt habe. Die Stellen der
Arbeit, die dem Wortlaut oder dem Sinne nach anderen Werken entnommen wurden,
sind in jedem Fall unter Angabe der Quelle kenntlich gemacht. Die Arbeit ist
noch nicht veröffentlicht oder in anderer Form als Prüfungsleistung vorgelegt
worden.

#{
  set line(stroke: .75pt, length: 15em)
  v(4em)
  grid(
    columns: 3,
    column-gutter: 1fr,
    row-gutter: .5em,
    align: center,
    line(), [], line(),
    [Ort, Datum], [], [Unterschrift],
  )
}

#pagebreak()

#heading(outlined: false)[Kurzfassung]
#{
  set text(lang: "de")
  [
    #rise ist eine abhängig typisierte funktionale Sprache fokussiert auf
    datenparallele Berechnungen. Sie ist Teil eines mehrstufigen
    Compiler-Frameworks, das aus mehreren Zwischenrepräsentationen besteht und
    die Spezialisierung von Programmen für die vorgesehene Hardware ermöglicht.
    Die bestehende Implementierung von #rise ist in Scala geschrieben, was den
    Beweis ihrer semantischen Eigenschaften und den Beweis von Übergängen zu
    späteren Stufen des Compiler-Frameworks erschwert. In dieser Arbeit
    implementieren wir (den Großteil von) #rise im Beweisassistenten Lean neu,
    um zukünftig als zentrale Quelle für #rise, seine zugehörigen
    Zwischenrepräsentationen und deren Beweise zu dienen. Ein wesentlicher
    Bestandteil unserer Implementierung ist die Typüberprüfung und Typinferenz
    von #rise\-Programmen. #rise ist abhängig typisiert, d. h., Typen können
    Terme enthalten. Beispielsweise enthalten Arrays ihre Länge als natürliche
    Zahl in ihrem Typ. Wird eine Funktion auf ein Argument angewendet, muss der
    Argumenttyp gleich dem Typ des ersten Parameters der Funktion sein. Die
    Bestimmung dieser Gleichheit wird als Unifikation bezeichnet und stellt
    aufgrund der abhängigen Typen von #rise eine Herausforderung dar.
    Unifikation ist genau der Teil der Typüberprüfung und Typinferenz, den wir
    mittels _Equality Saturation_ (EqSat) unterstützen werden. Dies ist ein auf
    Termersetzung basierter Prozess, der häufig zur Programmoptimierung und für
    Gleichheitsbeweise eingesetzt wird. Wir verwenden EqSat sowohl für die
    _gleichungsbasierte Unifikation_, die die natürlichen Zahlentypen von #rise
    unifiziert, als auch für die _syntaktische Unifikation erster Stufe_, die
    die übrigen Typen von #rise unifiziert. Da EqSat ein sehr flexibler Prozess
    ist, untersuchen wir auch seine Eignung als sprachunabhängige, erweiterbare
    Unifikationsmethode. Dies würde es uns ermöglichen, unseren Prozess für
    andere Sprachen mit unterschiedlichen Typsystemen zu verwenden. Wir stellen
    fest, dass EqSat aufgrund mangelhafter Laufzeit nicht gut für die
    algebraische Vereinfachung natürlicher Zahlen geeignet ist. Darüber hinaus
    identifizieren wir verschiedene Probleme hinsichtlich Korrektheit und
    Vollständigkeit, was uns letztendlich zu der Annahme führt, dass das System
    von #rise erweitert werden muss, um über Constraints ("Einschränkungen") zu
    argumentieren. Dennoch implementieren wir erfolgreich die syntaktische
    Unifikation erster Stufe mit EqSat und bieten einen alternativen Ansatz zur
    gleichungsbasierten Unifikation unter Verwendung des Computeralgebrasystems
    SymPy.
  ]
}
// #pagebreak()

#heading(outlined: false)[Abstract]
#rise is a dependently typed functional language with a focus on data-parallel
computation. It is part of a staged compiler framework that consists of multiple
intermediate representations and allows specialization of programs towards
intended hardware. #rise's existing implementation is written in Scala, which
complicates proving its semantic properties and proving transitions to later
stages of the compiler framework. In this work, we re-implement (the majority
of) #rise in the proof assistant Lean to serve -- in the future -- as a single
source of truth for #rise, its related intermediate representations, and proofs
thereof. A crucial part of our implementation is type checking and type
inference of #rise programs. #rise is dependently typed, i.e., types may contain
terms. For example, arrays contain their length as a natural number in their
type. Whenever a function is applied to an argument, the argument type must be
equal to the type of the first parameter of the function. Determining this
equality is called unification, and presents a challenge due to #rise's
dependent types. Unification is precisely where we support type checking and
type inference with _Equality Saturation_ (EqSat), which is a rewrite-based
process that is commonly used for program optimization and equational reasoning.
We employ EqSat to perform both _equational unification_, which unifies #rise's
natural number type components, and _syntactic first-order unification_, which
unifies the remainder of #rise's types. Since EqSat is a highly malleable
process, we also evaluate its suitability as a language-agnostic, extensible
unification engine. This would allow us to use our process for other languages
with different type systems. We find that EqSat is not well-suited to perform
algebraic simplification of natural numbers due to poor runtime performance.
Additionally, we identify various issues with soundness and completeness, which
ultimately leads us to believe that #rise's type system needs to be extended to
reason about constraints. Nevertheless, we successfully implement syntactic
first-order unification with EqSat, and offer an alternative approach to
equational unification by employing the computer algebra system SymPy.

#outline(
  depth: 3,
  // title: [Inhaltsverzeichnis],
)

#pagebreak()
