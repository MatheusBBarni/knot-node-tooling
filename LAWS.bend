import Base
import ./src/sri.bend as Sri
import ./src/semver.bend as Semver

law sri_accepts_matching_digest:
  {Sri.sri_ok("abc", "sha512-abc") == True{} : Bool}

law sri_rejects_mismatched_digest:
  {Sri.sri_ok("abc", "sha512-xyz") == False{} : Bool}

law sri_rejects_missing_algorithm:
  {Sri.sri_ok("abc", "abc") == False{} : Bool}

law sri_rejects_wrong_algorithm:
  {Sri.sri_ok("abc", "sha256-abc") == False{} : Bool}

law exact_spec_accepts_same_version:
  {Semver.satisfies("1.0.0", "1.0.0") == True{} : Bool}

law exact_spec_rejects_other_version:
  {Semver.satisfies("1.0.0", "1.0.1") == False{} : Bool}

law tilde_sat_accepts_higher_patch:
  {Semver.tilde_sat(Semver.Semver{1n, 2n, 5n}, Semver.Semver{1n, 2n, 0n}) == True{} : Bool}

law tilde_sat_rejects_next_minor:
  {Semver.tilde_sat(Semver.Semver{1n, 3n, 0n}, Semver.Semver{1n, 2n, 0n}) == False{} : Bool}

law star_spec_accepts_any_version:
  {Semver.satisfies("*", "2.0.0") == True{} : Bool}

law ge_sat_accepts_higher:
  {Semver.semver_ge(Semver.Semver{2n, 0n, 0n}, Semver.Semver{1n, 2n, 0n}) == True{} : Bool}

law ge_sat_rejects_lower:
  {Semver.semver_ge(Semver.Semver{1n, 0n, 0n}, Semver.Semver{1n, 2n, 0n}) == False{} : Bool}

law gt_sat_accepts_higher:
  {Semver.semver_gt(Semver.Semver{2n, 0n, 0n}, Semver.Semver{1n, 5n, 0n}) == True{} : Bool}

law gt_sat_rejects_equal:
  {Semver.semver_gt(Semver.Semver{1n, 5n, 0n}, Semver.Semver{1n, 5n, 0n}) == False{} : Bool}

law le_sat_accepts_lower:
  {Semver.semver_le(Semver.Semver{1n, 5n, 0n}, Semver.Semver{2n, 0n, 0n}) == True{} : Bool}

law le_sat_rejects_higher:
  {Semver.semver_le(Semver.Semver{2n, 0n, 0n}, Semver.Semver{1n, 5n, 0n}) == False{} : Bool}

law lt_sat_accepts_lower:
  {Semver.semver_lt(Semver.Semver{1n, 0n, 0n}, Semver.Semver{1n, 5n, 0n}) == True{} : Bool}

law lt_sat_rejects_equal:
  {Semver.semver_lt(Semver.Semver{1n, 5n, 0n}, Semver.Semver{1n, 5n, 0n}) == False{} : Bool}









