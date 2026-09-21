import Base

type Semver is Data:
  Semver{major: Nat, minor: Nat, patch: Nat}

type NatRest is Data:
  NatRest{n: Nat, rest: String}

def take_digits(s: String, acc: String) -> String & String:
  match s:
    case SNil{}:
      (acc, "")
    case SCon{'0', t}:
      take_digits(t, acc ++ SCon{'0', SNil{}})
    case SCon{'1', t}:
      take_digits(t, acc ++ SCon{'1', SNil{}})
    case SCon{'2', t}:
      take_digits(t, acc ++ SCon{'2', SNil{}})
    case SCon{'3', t}:
      take_digits(t, acc ++ SCon{'3', SNil{}})
    case SCon{'4', t}:
      take_digits(t, acc ++ SCon{'4', SNil{}})
    case SCon{'5', t}:
      take_digits(t, acc ++ SCon{'5', SNil{}})
    case SCon{'6', t}:
      take_digits(t, acc ++ SCon{'6', SNil{}})
    case SCon{'7', t}:
      take_digits(t, acc ++ SCon{'7', SNil{}})
    case SCon{'8', t}:
      take_digits(t, acc ++ SCon{'8', SNil{}})
    case SCon{'9', t}:
      take_digits(t, acc ++ SCon{'9', SNil{}})
    case SCon{h, t}:
      (acc, SCon{h, t})

def parse_semver.part_nat(rest: String, n: Maybe<&2, Nat>) -> Maybe<&2, NatRest>:
  match n:
    case None{}:
      None{}
    case Some{v}:
      Some{NatRest{v, rest}}

def parse_semver.part_from(ds: String & String) -> Maybe<&2, NatRest>:
  (digits, rest) = ds
  parse_semver.part_nat(rest, Nat.read(digits))

def parse_semver.part(s: String) -> Maybe<&2, NatRest>:
  parse_semver.part_from(take_digits(s, ""))

def parse_semver.end(major: Nat, minor: Nat, patch: Nat, rest: String) -> Maybe<&2, Semver>:
  match rest:
    case SNil{}:
      Some{Semver{major, minor, patch}}
    case _:
      None{}

def parse_semver.patch(major: Nat, minor: Nat, m: Maybe<&2, NatRest>) -> Maybe<&2, Semver>:
  match m:
    case None{}:
      None{}
    case Some{NatRest{patch, rest}}:
      parse_semver.end(major, minor, patch, rest)

def parse_semver.dot2(major: Nat, minor: Nat, rest: String) -> Maybe<&2, Semver>:
  match rest:
    case SNil{}:
      Some{Semver{major, minor, 0n}}
    case SCon{'.', t}:
      parse_semver.patch(major, minor, parse_semver.part(t))
    case _:
      None{}

def parse_semver.minor(major: Nat, m: Maybe<&2, NatRest>) -> Maybe<&2, Semver>:
  match m:
    case None{}:
      None{}
    case Some{NatRest{minor, rest}}:
      parse_semver.dot2(major, minor, rest)

def parse_semver.dot(rest: String, major: Nat) -> Maybe<&2, Semver>:
  match rest:
    case SNil{}:
      Some{Semver{major, 0n, 0n}}
    case SCon{'.', t}:
      parse_semver.minor(major, parse_semver.part(t))
    case _:
      None{}

def parse_semver.dot_from(m: Maybe<&2, NatRest>) -> Maybe<&2, Semver>:
  match m:
    case None{}:
      None{}
    case Some{NatRest{major, rest}}:
      parse_semver.dot(rest, major)

def parse_semver(s: String) -> Maybe<&2, Semver>:
  parse_semver.dot_from(parse_semver.part(s))

def semver_cmp.min(an: Nat, ap: Nat, bn: Nat, bp: Nat, c: Cmp) -> Cmp:
  match c:
    case LT{}:
      LT{}
    case GT{}:
      GT{}
    case EQ{}:
      Nat.cmp(ap, bp)

def semver_cmp.maj(am: Nat, +an: Nat, +ap: Nat, bm: Nat, +bn: Nat, +bp: Nat, c: Cmp) -> Cmp:
  match c:
    case LT{}:
      LT{}
    case GT{}:
      GT{}
    case EQ{}:
      semver_cmp.min(an, ap, bn, bp, Nat.cmp(an, bn))

def semver_cmp(a: Semver, b: Semver) -> Cmp:
  Semver{+am, +an, +ap} = a
  Semver{+bm, +bn, +bp} = b
  semver_cmp.maj(am, an, ap, bm, bn, bp, Nat.cmp(am, bm))

def semver_ge(a: Semver, b: Semver) -> Bool:
  Cmp.is_ge(semver_cmp(a, b))

def caret_sat(+v: Semver, +lo: Semver) -> Bool:
  Semver{+vm, vn, vp} = v
  Semver{+lm, ln, lp} = lo
  Bool.and(Nat.is_eq(vm, lm), semver_ge(v, lo))

def caret_sat_m(v: Maybe<&2, Semver>, lo: Maybe<&2, Semver>) -> Bool:
  match v lo:
    case Some{a} Some{b}:
      caret_sat(a, b)
    case _ _:
      False{}

def tilde_sat(+v: Semver, +lo: Semver) -> Bool:
  Semver{+vm, +vn, vp} = v
  Semver{+lm, +ln, lp} = lo
  Bool.and(Nat.is_eq(vm, lm), Bool.and(Nat.is_eq(vn, ln), semver_ge(v, lo)))

def tilde_sat_m(v: Maybe<&2, Semver>, lo: Maybe<&2, Semver>) -> Bool:
  match v lo:
    case Some{a} Some{b}:
      tilde_sat(a, b)
    case _ _:
      False{}

def ge_sat_m(v: Maybe<&2, Semver>, lo: Maybe<&2, Semver>) -> Bool:
  match v lo:
    case Some{a} Some{b}:
      semver_ge(a, b)
    case _ _:
      False{}

def semver_gt(a: Semver, b: Semver) -> Bool:
  Cmp.is_gt(semver_cmp(a, b))

def gt_sat_m(v: Maybe<&2, Semver>, lo: Maybe<&2, Semver>) -> Bool:
  match v lo:
    case Some{a} Some{b}:
      semver_gt(a, b)
    case _ _:
      False{}

def semver_le(a: Semver, b: Semver) -> Bool:
  Cmp.is_le(semver_cmp(a, b))

def le_sat_m(v: Maybe<&2, Semver>, hi: Maybe<&2, Semver>) -> Bool:
  match v hi:
    case Some{a} Some{b}:
      semver_le(a, b)
    case _ _:
      False{}

def semver_lt(a: Semver, b: Semver) -> Bool:
  Cmp.is_lt(semver_cmp(a, b))

def lt_sat_m(v: Maybe<&2, Semver>, hi: Maybe<&2, Semver>) -> Bool:
  match v hi:
    case Some{a} Some{b}:
      semver_lt(a, b)
    case _ _:
      False{}


def satisfies_atom(+spec: String, +ver: String) -> Bool:
  match spec:
    case SCon{'^', range}:
      caret_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case SCon{'~', range}:
      tilde_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case SCon{'*', SNil{}}:
      True{}
    case SCon{'>', SCon{'=', range}}:
      ge_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case SCon{'>', range}:
      gt_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case SCon{'<', SCon{'=', range}}:
      le_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case SCon{'<', range}:
      lt_sat_m(parse_semver(ver), parse_semver(String.trim(range)))
    case _:
      String.eq(spec, ver)

def atom_sat(+atom: String, +ver: String) -> Bool:
  match atom:
    case SNil{}:
      False{}
    case _:
      satisfies_atom(atom, ver)

def or_sat(parts: List<&2, String>, +ver: String) -> Bool:
  match parts:
    case Nil{}:
      False{}
    case Con{+p, rest}:
      Bool.or(atom_sat(String.trim(p), ver), or_sat(rest, ver))

def satisfies(+spec: String, +ver: String) -> Bool:
  or_sat(String.split(spec, '|'), ver)





def better_cmp(+a: String, +b: String, c: Cmp) -> String:
  match c:
    case LT{}:
      b
    case _:
      a

def better_m(+a: String, +b: String, am: Maybe<&2, Semver>, bm: Maybe<&2, Semver>) -> String:
  match am bm:
    case Some{x} Some{y}:
      better_cmp(a, b, semver_cmp(x, y))
    case _ _:
      a

def better(+a: String, +b: String) -> String:
  better_m(a, b, parse_semver(a), parse_semver(b))

def pick_max(best: Maybe<&2, String>, v: String) -> String:
  match best:
    case None{}:
      v
    case Some{b}:
      better(b, v)

def pick_next(best: Maybe<&2, String>, v: String, ok: Bool) -> Maybe<&2, String>:
  match ok:
    case False{}:
      best
    case True{}:
      Some{pick_max(best, v)}

def pick(xs: List<&2, String>, +spec: String, best: Maybe<&2, String>) -> Maybe<&2, String>:
  match xs:
    case Nil{}:
      best
    case Con{SNil{}, rest}:
      pick(rest, spec, best)
    case Con{+v, rest}:
      pick(rest, spec, pick_next(best, v, satisfies(spec, v)))

def select_version(spec: String, versions: List<&2, String>) -> Maybe<&2, String>:
  pick(versions, spec, None{})
