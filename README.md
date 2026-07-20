# tilezz ZZ12 perimeter<=14 tiling-classification certificates

A complete, machine-checkable certificate store: for **every** free simple
matchstick polygon (self-avoiding unit-edge polygon, turn angles in multiples
of `2*pi/12`) on the cyclotomic ring `Z[zeta_12]` with perimeter `<= 14`, a
small combinatorial certificate of whether it tiles the plane.

**33,279,563 tiles classified** (P / N / U = **480,286 / 32,799,276 / 1**):

- **480,286** tile the plane **periodically** (an NP-witness: a fundamental
  domain plus its self-gluing / lattice rule).
- **32,799,276** provably **cannot tile** the plane (a finite Heesch number:
  a sample gap-free k-corona plus the exhausted search that shows no k+1
  corona exists).
- **1** is left **Undecided**, and it is the **SPECTRE** (dafsa index
  `31434778`, canonical turn word `[-3,2,0,2,3,-2,3,-2,3,2,-3,2,3,2]`, the
  mirror chirality of the Smith-Myers-Kaplan-Goodman-Strauss aperiodic
  monotile).

## The claim

Every perimeter-`<=14` free ZZ12 tile is certifiably a non-tiler or a periodic
tiler **except** the spectre. Combined with the spectre's known aperiodicity
(Smith, Myers, Kaplan, Goodman-Strauss 2023), this store is a proof that the
**spectre is the minimal-perimeter chiral aperiodic ZZ12 monotile**, and the
unique such tile at perimeter 14.

**Scope (stated honestly):** single-chirality (rotations only, no reflected
copies) and edge-to-edge, the latter resting on the pipeline's own
edge-to-edge reduction theorem (`docs/edge_to_edge_reduction.md` in tilezz;
external review pending). The `CannotTile` soundness and the `Periodic`
verification are both exact (integer / ring arithmetic, no floating point
decides a verdict).

## Files (the store is split for GitHub's 100 MB limit)

| file | bytes | sha256 |
|------|-------|--------|
| `zz12_le14_certs.jsonl.gz.aa` | 61371488 | `4b3c953d068b108e967b48a03e0438b0c23acc09ed06c7d47a3b38a52efccb10` |
| `zz12_le14_certs.jsonl.gz.ab` | 61371487 | `d132b470a9257685335476e5773441fadc56577c9cd1947cb62ca15fea278589` |

Reassemble and decompress:

```sh
cat zz12_le14_certs.jsonl.gz.aa zz12_le14_certs.jsonl.gz.ab > zz12_le14_certs.jsonl.gz
# verify the reassembled archive:
sha256sum zz12_le14_certs.jsonl.gz
# -> 84dec4a859b36203eac8334a75956e39cf97d34cfb39ece9f1ab919f1199251a
gunzip zz12_le14_certs.jsonl.gz          # -> zz12_le14_certs.jsonl (~4.2 GB, packed)
```

## Format

JSONL, one line per tile, **packed** (sorted ascending by dafsa index) so
`--lookup` can binary-search it:

```
<dafsa_index>\t<Classified JSON>
```

The index is the tile's position in the **free ZZ12 rat DAFSA** under the
`(length, lex)` canonical ordering -- identical to the `zz12_n16_free` dataset
for perimeters `<= 14`. `Classified` is one of:

- `{"Decided":{"Periodic":{"build":[...],"glue":[...],"via":...}}}`
  -- replay `build` to assemble the fundamental domain (a meta-tile of `k`
  base copies), then `glue` clones it across the lattice unboundedly.
- `{"Decided":{"CannotTile":{"heesch":k,"status":"Finite","build":[...],...}}}`
  -- `build` is a sample gap-free `k`-corona (Heesch >= k); `status:"Finite"`
  means the search exhausted (no `k+1`-corona), a sound cannot-tile proof.
- `{"Undecided":{"depth":d,"corona":[...]}}` -- the one aperiodic candidate
  (the spectre).

Every certificate is purely combinatorial (pairs of edge indices); the base
tile's geometry is recovered from the DAFSA by index, so a cert is
content-addressable and re-checkable with no stored coordinates.

## Verifying

The bundled `verify.sh` does the whole thing end-to-end -- integrity-checks and
reassembles the split store, fetches the pinned `zz12_n16_free` DAFSA, builds
`classify_tiles` from a pinned tilezz release (`v0.2.0`) with a provenance
guard, then replays and coverage-checks every certificate:

```sh
sh verify.sh
```

Or, with [tilezz](https://github.com/apirogov/tilezz) and the `zz12_n16_free`
dataset already present, run the check directly:

```sh
# independent re-check of every cert + coverage completeness:
classify_tiles --asset zz12_n16_free --verify --store zz12_le14_certs.jsonl
# point-query a single tile:
classify_tiles --asset zz12_n16_free --lookup 31434778   # the spectre
```

## Provenance

- Produced by [tilezz](https://github.com/apirogov/tilezz) (the
  tile-classification pipeline), 2026-07-07; code lineage commit `6bc2c7b`.
- Author: Anton Pirogov, ORCID
  [0000-0002-5077-7497](https://orcid.org/0000-0002-5077-7497).
- License: [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/).
