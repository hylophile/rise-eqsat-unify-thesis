#import "base.typ": *

= #rise Primitives (selection) <rise-primitives>
#{
  set text(size: .7em)
  ```rise
    def id  : {t : data} → t → t
    def neg : {t : data} → t → t

    def add : {t : data} → t → t → t
    def sub : {t : data} → t → t → t
    def mul : {t : data} → t → t → t
    def div : {t : data} → t → t → t
    def mod : {t : data} → t → t → t

    def select : {t : data} → bool → t → t → t

    def not   : bool → bool
    def gt    : {t : data} → t → t → bool
    def lt    : {t : data} → t → t → bool
    def equal : {t : data} → t → t → bool

    def cast : {s t : data} → s → t
    def indexAsNat : {n : nat} → idx[n] → natType
    def natAsIndex : (n : nat) → natType → idx[n]

    def generate : {n : nat} → {t : data} → (idx[n] → t) → n·t
    def    index : {n : nat} → {t : data} → idx[n] → n·t → t

    def   take : (n : nat) → {  m : nat} → {t : data} → (n+m)·t → n·t
    def   drop : (n : nat) → {  m : nat} → {t : data} → (n+m)·t → m·t
    def concat :             {n m : nat} → {t : data} → n·t → m·t → (n+m)·t

    def split : (n : nat) → {  m : nat} → {t : data} → (m*n)·t → m·n·t
    def  join :             {n m : nat} → {t : data} → n·m·t → (n*m)·t

    def          slide : {n : nat} → (sz sp    : nat) → {  t : data} → (sp*n+sz)·t → (1+n)·sz·t
    def circularBuffer : {n : nat} → (alloc sz : nat) → {s t : data} → (s → t) → (n-1+sz)·s → n·sz·t
    def   rotateValues : {n : nat} → (sz       : nat) → {  t : data} → (t → t) → (n-1+sz)·t → n·sz·t

    def transpose : {n m : nat} → {t : data} → n·m·t → m·n·t

    def  gather : {n m : nat} → {t : data} → m·idx[n] → n·t → m·t
    def scatter : {n m : nat} → {t : data} → n·idx[m] → n·t → m·t

    def padCst   : {n : nat} → (l r : nat) → {t : data} → t → n·t → (l+n+r)·t
    def padClamp : {n : nat} → (l r : nat) → {t : data} →     n·t → (l+n+r)·t
    def padEmpty : {n : nat} → (  r : nat) → {t : data} →     n·t →   (n+r)·t

    def   zip : {n : nat} → {s t : data} → n·s → n·t → n·(s × t)
    def unzip : {n : nat} → {s t : data} → n·(s × t) → (n·s × n·t)

    def makePair : {s t : data} → s → t → (s × t)
    def      fst : {s t : data} → (s × t) → s
    def      snd : {s t : data} → (s × t) → t

    def vectorFromScalar : {n : nat} → {t : data} → t → n<t>
    def asVectorAligned  : (n : nat) → {m : nat} → {t : data} → (m*n)·t → m·n<t>
    def asVector :         (n : nat) → {m : nat} → {t : data} → (m*n)·t → m·n<t>
    def asScalar :         {n : nat} → {m : nat} → {t : data} → m·n<t> → (m*n)·t

    def map    : {n : nat} → {s t : data} → (s → t) → n·s → n·t
    def reduce : {n : nat} → {s t : data} → (t → s → t) → t → n·s → t
    def scan   : {n : nat} → {s : data} → {t : data} → (s → t → t) → t → n·s → n·t
  ```
}
= #rise Grammar <rise-grammar>
$
  e ::= &#r("fun") x #r("=>") e |
  #r("fun") x : tau #r("=>") e
  &"Abstraction (term level)" \
  | &#r("fun") x : kappa #r("=>") e
  | #r("fun {") x : kappa #r("} =>") e
  &"Abstraction (type level)" \
  | &#r("let") x #r(":=") e #r("in") e &"Let-Binding" \
  | &e thick e | e #r("(")e#r(")") | e #r("|>") e | e #r("<|") e &"Application (term level)" \
  | &e #r("(")n #r(":") delta#r(")") &"Application (type level)" \
  | &e #r(">>") e | e #r("<<") e &"Function Composition"\
  | &e #r("*") e | e #r("+") e | e#r(".1") | e#r(".2") &"Syntax sugar for various primitives" \
  &&#text[(#r("mul"), #r("add"), #r("fst"), #r("snd"))] \
  | &x &"Identifier" \
  | &underline(l) &"Literal"\
  | &P &"Primitive"\
  \
  kappa ::= &#r("nat") &"Natural Number Kind"\
  | &#r("data") &"Datatype Kind" \
  \
  tau ::= &delta &"Datatype" \
  | &delta #r("→") delta &"Function Type" \
  | &#r("(")x #r(":") kappa#r(") →") tau | #r("{")x #r(":") kappa#r("} →") tau &#h(1cm)"Dependent Function Type"\
  &&"(explicit/implicit parameter)" \
  \
  n ::= &underline(0) &"Natural Number Literal" \
  | &x &"Identifier" \
  | &n #r("+") n |n #r("-") n| n #r("*") n | n #r("/") n &"Binary Operation" \
  // | &n #r("+") n |n #r("-") n| n #r("*") n | n #r("/") n | n #r("^") n &"Binary Operation" \
  \
  delta ::= &n #r("·") delta &"Array Type" \
  | &delta #r("×") delta &"Product Type" \
  | &#r("idx[")n#r("]") &"Index Type" \
  | &s &"Scalar Type" \
  | &n#r("<")s#r(">") &"Vector Type" \
  \
  s ::= &
  #r("natType")
  \ | &#r("bool") \
  | &#r("int")
  | #r("i8") \
  | &#r("i16")
  | #r("i32")
  | #r("i64") \
  | &#r("u8")
  | #r("u16")
  | #r("u32")
  | #r("u64") \
  | &#r("f16")
  | #r("f32")
  | #r("f64")
$
