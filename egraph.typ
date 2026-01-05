#import "base.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.3.4": draw

// #diagram(
//   node-corner-radius: 2pt,

//   node((1, 0), `/`, stroke: black, shape: "rect", name: <div>),
//   node((1, 1), `*`, stroke: black, shape: "rect", name: <mul>),
//   node((0, 2), `a`, stroke: black, shape: "rect", name: <var>),
//   node((2, 2), `2`, stroke: black, shape: "rect", name: <two>),
//   {
//     let eclassframe() = (stroke: (dash: "dashed"), inset: 5pt)
//     node(enclose: <div>, ..eclassframe(), name: <ediv>)
//     node(enclose: <mul>, ..eclassframe(), name: <emul>)
//     node(enclose: <var>, ..eclassframe(), name: <evar>)
//     node(enclose: <two>, ..eclassframe(), name: <etwo>)
//   },
//   edge(<div>, <etwo>, "-solid", bend: 30deg),
//   edge(<div>, <emul>, "-solid"),
//   edge(<mul>, <evar>, "-solid"),
//   edge(<mul>, <etwo>, "-solid"),
// )

// #diagram(
//   node-corner-radius: 2pt,
//   node((1, 0), `/`, stroke: black, shape: "rect", name: <div>),
//   node((1, 1), `*`, stroke: black, shape: "rect", name: <mul>),
//   node((2, 1), `<<`, stroke: black, shape: "rect", name: <shf>),
//   node((0, 2), `a`, stroke: black, shape: "rect", name: <var>),
//   node((2, 2), `2`, stroke: black, shape: "rect", name: <two>),
//   node((3, 2), `1`, stroke: black, shape: "rect", name: <one>),
//   {
//     let eclassframe() = (stroke: (dash: "dashed"), inset: 7pt)
//     node(enclose: <div>, ..eclassframe(), name: <ediv>)
//     node(enclose: (<mul>, <shf>), ..eclassframe(), name: <emul>)
//     node(enclose: <var>, ..eclassframe(), name: <evar>)
//     node(enclose: <two>, ..eclassframe(), name: <etwo>)
//     node(enclose: <one>, ..eclassframe(), name: <eone>)
//   },
//   edge(<div>, <etwo>, "-solid", bend: 80deg),
//   edge(<div>, <emul>, "-solid"),
//   edge(<mul>, <evar>, "-solid"),
//   edge(<mul>, <etwo>, "-solid"),
//   edge(<shf>, <eone>, "-solid"),
//   edge(<shf>, <evar>, "-solid"),
// )


// #diagram(
//   node-corner-radius: 5pt,
//   node-stroke: black,
//   node-shape: "rect",
//   node-fill: white,
//   node((1, 0), `/`, name: <div>),
//   node((3, 1), `/`, name: <div2>),
//   node((1, 1), `*`, name: <mul>),
//   node((3, 0), `*`, name: <mul2>),
//   node((2, 1), `<<`, name: <shf>),
//   node((0, 2), `a`, name: <var>),
//   node((2, 2), `2`, name: <two>),
//   node((3, 2), `1`, name: <one>),
//   {
//     let eclassframe() = (stroke: none, fill: blue.lighten(75%), inset: 5pt)
//     node(enclose: (<div>, <mul2>), ..eclassframe(), name: <ediv>)
//     node(enclose: (<div2>), ..eclassframe(), name: <ediv2>)
//     node(enclose: (<mul>, <shf>), ..eclassframe(), name: <emul>)
//     node(enclose: <var>, ..eclassframe(), name: <evar>)
//     node(enclose: <two>, ..eclassframe(), name: <etwo>)
//     node(enclose: <one>, ..eclassframe(), name: <eone>)
//   },
//
//   edge(<div>, <etwo>, "-solid", bend: 75deg),
//   edge(<div>, <emul>, "-solid"),
//   edge(<mul>, <evar>, "-solid"),
//   edge(<mul>, <etwo>, "-solid"),
//   edge(<shf>, <eone>, "-solid"),
//   edge(<shf>, <evar>, "-solid"),
//   edge(<mul2>, <evar>, "-solid", bend: -80deg),
//   edge(<mul2>, <ediv2>, "-solid"),
//   edge(<div2>, "r,d,d,l,l", <etwo>, shift: 2pt, "-solid"),
//   edge(<div2>, "r,d,d,l,l", <etwo>, shift: -2pt, "-solid"),
// )

#show raw: r => {
  set text(font: "CommitMono", size: 12pt)
  r
}



#scale(
  50%,
  reflow: true,
  stack(
    dir: ltr,
    spacing: 5em,
    diagram(
      ..diagram-conf,
      node((1, 0), enode-text(`/`), ..enode-conf, name: <div>),
      // node((3, 1), enode-text(`/`), ..enode-conf, name: <divr>),
      node((1, 1), enode-text(`*`), ..enode-conf, name: <mul>),
      // node((3, 0), enode-text(`*`), ..enode-conf, name: <mulr>),
      // node((2, 1), enode-text(`<<`), ..enode-conf, name: <shf>),
      node((0, 2), enode-text(`a`), ..enode-conf, name: <var>),
      node((2, 2), enode-text(`2`), ..enode-conf, name: <two>),
      // node((3, 2), enode-text(`1`), ..enode-conf, name: <one>),
      node(
        (0, 0),
        enode-text(`0`),
        ..enode-conf,
        name: <dummy>,
        post: x => draw.hide(x),
      ),

      node(enclose: <div>, ..eclass-conf, name: <ediv>),
      // node(enclose: <divr>, ..eclass-conf, name: <edivr>),
      node(enclose: <mul>, ..eclass-conf, name: <emul>),
      // node(enclose: <mulr>, ..eclass-conf, name: <emulr>),
      // node(enclose: <shf>, ..eclass-conf, name: <eshf>),
      node(enclose: <var>, ..eclass-conf, name: <evar>),
      node(enclose: <two>, ..eclass-conf, name: <etwo>),
      // node(enclose: <one>, ..eclass-conf, name: <eone>),

      // node(enclose: (<dummy>, <mulr>), ..eclass-conf, name: <edummymulr>),
      // node(enclose: (<dummy>, <var>), ..eclass-conf, name: <edummyvar>),
      // node(enclose: (<mul>, <shf>), ..eclass-conf, name: <emulshf>),
      // node(enclose: (<divr>, <one>), ..eclass-conf, name: <edivrone>),

      edge(<div>, shift: (-.125), <emul>, edge-mark, ..edge-conf),
      edge(
        <div>,
        (rel: (0, 0.5)),
        (rel: (1, 0)),
        (rel: (0, 1)),
        // (rel: (1.5, 0)),
        // (rel: (0, 1)),
        <etwo>,
        ..lshift,
        edge-mark,
        ..edge-conf,
      ),
      edge(<mul.south-west>, <evar>, edge-mark, ..edge-conf),
      edge(<mul.south-east>, <etwo>, edge-mark, ..edge-conf),
      // edge(<shf.south-east>, <eone>, edge-mark, ..edge-conf),
      // edge(<shf>, (rel: (-1, 1)), <evar>, edge-mark, ..edge-conf),
      // edge(<mulr>, <edivr>, shift: .125, edge-mark, ..edge-conf),
      // edge(
      //   <mulr>,
      //   (rel: (0, .5)),
      //   (rel: (.625, 0)),
      //   (rel: (0, 2.125)),
      //   (rel: (-3.25, 0)),
      //   <evar>,
      //   ..rshift,
      //   edge-mark,
      //   ..edge-conf,
      // ),
      // edge(
      //   <divr>,
      //   (rel: (0, 0.5)),
      //   (rel: (-1, 0)),
      //   ..lshift,
      //   <etwo>,
      //   edge-mark,
      //   ..edge-conf,
      // ),
      // edge(
      //   <divr>,
      //   (rel: (0, 0.5)),
      //   (rel: (-1, 0)),
      //   ..rshift,
      //   <etwo>,
      //   edge-mark,
      //   ..edge-conf,
      // ),
    ),
    diagram(
      ..diagram-conf,
      node((1, 0), enode-text(`/`), ..enode-conf, name: <div>),
      // node((3, 1), enode-text(`/`), ..enode-conf, name: <divr>),
      node((1, 1), enode-text(`*`), ..enode-conf, name: <mul>),
      // node((3, 0), enode-text(`*`), ..enode-conf, name: <mulr>),
      node((2, 1), enode-text-hl(`<<`), ..enode-conf-hl, name: <shf>),
      node((0, 2), enode-text(`a`), ..enode-conf, name: <var>),
      node((2, 2), enode-text(`2`), ..enode-conf, name: <two>),
      node((3, 2), enode-text-hl(`1`), ..enode-conf-hl, name: <one>),
      node(
        (0, 0),
        enode-text(`0`),
        ..enode-conf,
        name: <dummy>,
        post: x => draw.hide(x),
      ),

      node(enclose: <div>, ..eclass-conf, name: <ediv>),
      // node(enclose: <divr>, ..eclass-conf, name: <edivr>),
      node(enclose: <mul>, ..eclass-conf, name: <emul>),
      // node(enclose: <mulr>, ..eclass-conf, name: <emulr>),
      node(enclose: <shf>, ..eclass-conf, name: <eshf>),
      node(enclose: <var>, ..eclass-conf, name: <evar>),
      node(enclose: <two>, ..eclass-conf, name: <etwo>),
      node(enclose: <one>, ..eclass-conf-hl, name: <eone>),

      // node(enclose: (<dummy>, <mulr>), ..eclass-conf, name: <edummymulr>),
      // node(enclose: (<dummy>, <var>), ..eclass-conf, name: <edummyvar>),
      node(enclose: (<mul>, <shf>), ..eclass-conf-hl, name: <emulshf>),
      // node(enclose: (<divr>, <one>), ..eclass-conf, name: <edivrone>),

      edge(<div>, shift: (-.125), <emul>, edge-mark, ..edge-conf),
      edge(
        <div>,
        (rel: (0, 0.5)),
        (rel: (1.5, 0)),
        (rel: (0, 1)),
        <etwo>,
        ..lshift,
        edge-mark,
        ..edge-conf,
      ),
      edge(<mul.south-west>, <evar>, edge-mark, ..edge-conf),
      edge(<mul.south-east>, <etwo>, edge-mark, ..edge-conf),
      edge(<shf.south-east>, <eone>, edge-mark, ..edge-conf-hl),
      edge(<shf>, (rel: (-1, 1)), <evar>, edge-mark, ..edge-conf-hl),
      // edge(<mulr>, <edivr>, shift: .125, edge-mark, ..edge-conf),
      // edge(
      //   <mulr>,
      //   (rel: (0, .5)),
      //   (rel: (.625, 0)),
      //   (rel: (0, 2.125)),
      //   (rel: (-3.25, 0)),
      //   <evar>,
      //   ..rshift,
      //   edge-mark,
      //   ..edge-conf,
      // ),
      // edge(
      //   <divr>,
      //   (rel: (0, 0.5)),
      //   (rel: (-1, 0)),
      //   ..lshift,
      //   <etwo>,
      //   edge-mark,
      //   ..edge-conf,
      // ),
      // edge(
      //   <divr>,
      //   (rel: (0, 0.5)),
      //   (rel: (-1, 0)),
      //   ..rshift,
      //   <etwo>,
      //   edge-mark,
      //   ..edge-conf,
      // ),
    ),
    diagram(
      ..diagram-conf,
      node((1, 0), enode-text(`/`), ..enode-conf, name: <div>),
      node((3, 1), enode-text-hl(`/`), ..enode-conf-hl, name: <divr>),
      node((1, 1), enode-text(`*`), ..enode-conf, name: <mul>),
      node((3, 0), enode-text-hl(`*`), ..enode-conf-hl, name: <mulr>),
      node((2, 1), enode-text(`<<`), ..enode-conf, name: <shf>),
      node((0, 2), enode-text(`a`), ..enode-conf, name: <var>),
      node((2, 2), enode-text(`2`), ..enode-conf, name: <two>),
      node((3, 2), enode-text(`1`), ..enode-conf, name: <one>),
      node(
        (0, 0),
        enode-text(`0`),
        ..enode-conf,
        name: <dummy>,
        post: x => draw.hide(x),
      ),

      node(enclose: <div>, ..eclass-conf, name: <ediv>),
      node(enclose: <divr>, ..eclass-conf-hl, name: <edivr>),
      node(enclose: <mul>, ..eclass-conf, name: <emul>),
      node(enclose: <mulr>, ..eclass-conf, name: <emulr>),
      node(enclose: <shf>, ..eclass-conf, name: <eshf>),
      node(enclose: <var>, ..eclass-conf, name: <evar>),
      node(enclose: <two>, ..eclass-conf, name: <etwo>),
      node(enclose: <one>, ..eclass-conf, name: <eone>),

      // node(enclose: (<dummy>, <mulr>), ..eclass-conf, name: <edummymulr>),
      // node(enclose: (<dummy>, <var>), ..eclass-conf, name: <edummyvar>),
      node(enclose: (<mul>, <shf>), ..eclass-conf, name: <emulshf>),
      node(enclose: (<div>, <mulr>), ..eclass-conf-hl, name: <edivmulr>),
      // node(enclose: (<divr>, <one>), ..eclass-conf, name: <edivrone>),

      edge(<div>, shift: (-.125), <emul>, edge-mark, ..edge-conf),
      edge(
        <div>,
        (rel: (0, 0.5)),
        (rel: (1.5, 0)),
        (rel: (0, 1)),
        <etwo>,
        ..lshift,
        edge-mark,
        ..edge-conf,
      ),
      edge(<mul.south-west>, <evar>, edge-mark, ..edge-conf),
      edge(<mul.south-east>, <etwo>, edge-mark, ..edge-conf),
      edge(<shf.south-east>, <eone>, edge-mark, ..edge-conf),
      edge(<shf>, (rel: (-1, 1)), <evar>, edge-mark, ..edge-conf),
      edge(<mulr>, <edivr>, shift: .125, edge-mark, ..edge-conf-hl),
      edge(
        <mulr>,
        (rel: (0, .5)),
        (rel: (.625, 0)),
        (rel: (0, 2.125)),
        (rel: (-3.25, 0)),
        <evar>,
        ..rshift,
        edge-mark,
        ..edge-conf-hl,
      ),
      edge(
        <divr>,
        (rel: (0, 0.5)),
        (rel: (-1, 0)),
        ..lshift,
        <etwo>,
        edge-mark,
        ..edge-conf-hl,
      ),
      edge(
        <divr>,
        (rel: (0, 0.5)),
        (rel: (-1, 0)),
        ..rshift,
        <etwo>,
        edge-mark,
        ..edge-conf-hl,
      ),
    ),
    diagram(
      ..diagram-conf,
      node((1, 0), enode-text(`/`), ..enode-conf, name: <div>),
      node((3, 1), enode-text(`/`), ..enode-conf, name: <divr>),
      node((1, 1), enode-text(`*`), ..enode-conf, name: <mul>),
      node((3, 0), enode-text(`*`), ..enode-conf, name: <mulr>),
      node((2, 1), enode-text(`<<`), ..enode-conf, name: <shf>),
      node((0, 2), enode-text(`a`), ..enode-conf, name: <var>),
      node((2, 2), enode-text(`2`), ..enode-conf, name: <two>),
      node((3, 2), enode-text(`1`), ..enode-conf, name: <one>),
      node(
        (0, 0),
        enode-text(`0`),
        ..enode-conf,
        name: <dummy>,
        post: x => draw.hide(x),
      ),

      node(enclose: <div>, ..eclass-conf, name: <ediv>),
      node(enclose: <divr>, ..eclass-conf, name: <edivr>),
      node(enclose: <mul>, ..eclass-conf, name: <emul>),
      node(enclose: <mulr>, ..eclass-conf, name: <emulr>),
      node(enclose: <shf>, ..eclass-conf, name: <eshf>),
      node(enclose: <var>, ..eclass-conf, name: <evar>),
      node(enclose: <two>, ..eclass-conf, name: <etwo>),
      node(enclose: <one>, ..eclass-conf, name: <eone>),

      node(enclose: (<dummy>, <mulr>), ..eclass-conf-hl, name: <edummymulr>),
      node(enclose: (<dummy>, <var>), ..eclass-conf-hl, name: <edummyvar>),
      node(enclose: (<mul>, <shf>), ..eclass-conf, name: <emulshf>),
      node(enclose: (<divr>, <one>), ..eclass-conf-hl, name: <edivrone>),

      edge(<div>, shift: (-.125), <emul>, edge-mark, ..edge-conf),
      edge(
        <div>,
        (rel: (0, 0.5)),
        (rel: (1.5, 0)),
        (rel: (0, 1)),
        <etwo>,
        ..lshift,
        edge-mark,
        ..edge-conf,
      ),
      edge(<mul.south-west>, <evar>, edge-mark, ..edge-conf),
      edge(<mul.south-east>, <etwo>, edge-mark, ..edge-conf),
      edge(<shf.south-east>, <eone>, edge-mark, ..edge-conf),
      edge(<shf>, (rel: (-1, 1)), <evar>, edge-mark, ..edge-conf),
      edge(<mulr>, <edivr>, shift: .125, edge-mark, ..edge-conf),
      edge(
        <mulr>,
        (rel: (0, .5)),
        (rel: (.625, 0)),
        (rel: (0, 2.125)),
        (rel: (-3.25, 0)),
        <evar>,
        ..rshift,
        edge-mark,
        ..edge-conf,
      ),
      edge(
        <divr>,
        (rel: (0, 0.5)),
        (rel: (-1, 0)),
        ..lshift,
        <etwo>,
        edge-mark,
        ..edge-conf,
      ),
      edge(
        <divr>,
        (rel: (0, 0.5)),
        (rel: (-1, 0)),
        ..rshift,
        <etwo>,
        edge-mark,
        ..edge-conf,
      ),
    ),
  ),
)
