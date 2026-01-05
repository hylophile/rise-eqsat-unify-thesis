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
#q[todo]
// #pagebreak()

#heading(outlined: false)[Abstract]
#q[todo]
// #pagebreak()


#outline(
  depth: 3,
  // title: [Inhaltsverzeichnis],
)

#pagebreak()
