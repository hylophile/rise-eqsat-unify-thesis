#import "base.typ": *
#grid(
  columns: 2,
  gutter: 1.5em,
  grid.cell(
    colspan: 2,
    ir(
      $G union {f(s_0,dots,s_k) uni f(t_0,dots,t_k)}$,
      $G union {s_0 uni t_0,dots,s_k uni t_k}$,
      label: [U-Decompose],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {t uni t}$,
      $G$,
      label: [U-Delete],
    ),
  ),
  grid.cell(
    colspan: 1,
    ir(
      $G union {f(s_0,dots,s_k) uni meta(x)}$,
      $G union {meta(x) uni f(s_0,dots,s_k)}$,
      label: [U-Swap],
    ),
  ),
  grid.cell(
    colspan: 2,
    ir(
      (
        $G union {meta(x) uni t}$,
        $meta(x) in.not "mvars"(t) and meta(x) in "mvars"(G)$,
      ),
      $G[meta(x) |-> t] union {meta(x) uni t}$,
      label: [U-Eliminate],
    ),
  ),
  grid.cell(
    colspan: 2,
    ir(
      (
        $G union {f(s_0,dots,s_k) uni g(t_0,dots,t_m)}$,
        $f eq.not g or k eq.not m$,
      ),
      $bot$,
      label: [U-Conflict],
    ),
  ),
  grid.cell(
    colspan: 2,
    ir(
      (
        $G union {meta(x) uni f(s_0,dots,s_k)}$,
        $meta(x) in "mvars"(f(s_0,dots,s_k))$,
      ),
      $bot$,
      label: [U-Check],
    ),
  ),
)
