# tilezz simple matchstick polygons on Z[zeta_9], perimeter <= 18, free

Simple matchstick polygons -- closed self-avoiding polygonal walks with unit-length edges and turn angles in integer multiples of `2*pi/9` -- on the cyclotomic ring `Z[zeta_9]`, with perimeter up to 18, canonicalised under free (full dihedral symmetry reduction) symmetry. 503397962 sequences.

## Turn-angle units

Z[zeta_9] has no native lattice in tilezz, so this dataset is the order-9 sub-ring of Z[zeta_18] -- the turn directions that are multiples of 2 -- enumerated with `--step 2`. Each stored turn is therefore a Z[zeta_18] turn (an integer multiple of `2*pi/18`, always even) and is `2` times the corresponding Z[zeta_9] turn (a multiple of `2*pi/9`).

To read the sequences as Z[zeta_9] turns, divide every stored value by `2`. For example the regular 9-gon is stored as `2 2 2 2 2 2 2 2 2` and is `1 1 1 1 1 1 1 1 1` in Z[zeta_9]. The web explorer shows the halved Z[zeta_9] form; `tools/decode.py` prints the raw stored Z[zeta_18] values.

## Copyright

Copyright (c) 2026 Anton Pirogov. All rights reserved subject to the license below.

## License

This dataset is distributed under the [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/) (CC-BY-SA-4.0). In short:

- **Attribution** -- credit the original author(s) above and link back to the source repository (https://github.com/apirogov/tilezz).
- **ShareAlike** -- if you remix, transform, or build upon this dataset, distribute your contributions under the same license.

The full license text is at <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.

## Contents

This directory is a [RO-Crate 1.2](https://www.researchobject.org/ro-crate/specification/1.2/) asset. The entry point is `ro-crate-metadata.json`; every file listed below is also recorded there with a `sha256`, an `encodingFormat`, and (where applicable) a `conformsTo` pointer to its schema.

```
tilezz-rat-zz9-n18-free/
  README.md               this file
  ro-crate-metadata.json  RO-Crate 1.2 manifest (start here for tooling)
  block_index.json        DAFSA wire manifest (counts, root state, sha256 block index)
  schemas/
    block_index.schema.json  formal JSON Schema (draft 2020-12)
    blocks_schema.txt        prose spec covering JSON + .bin formats
    rat_schema.txt           length-prefix convention inside the DAFSA
  blocks/
    <sha256>.bin            one gzipped DAFSA block each; filename = SHA-256 of file
  tools/
    decode.py               standalone Python 3 decoder (no deps)
    verify_sha256.py        SHA-256 verifier (no deps; exits 0 on full match)
    count.py                per-perimeter family terms (--print) + re-derive/verify (--verify)
    verify_canonical.py     independently check every rat is dihedral-canonical CCW
    reproduce.sh            executable rebuild script (clones + builds + runs)
```

## Extracting sequences (no Rust toolchain needed)

`tools/decode.py` walks the blocked DAFSA and prints every sequence as a line of space-separated signed integers:

```sh
python3 tools/decode.py > rats.txt
```

The line count of `rats.txt` must equal `n_sequences` from `block_index.json`.

## Verifying SHA-256s

Every File entity in `ro-crate-metadata.json` carries a `sha256` that matches the on-disk bytes. `tools/verify_sha256.py` checks the whole set:

```sh
python3 tools/verify_sha256.py
```

Exits 0 on full match, 1 on any mismatch.

## Reproducing from source

Produced by [`tilezz`](https://github.com/apirogov/tilezz) v0.1.4, commit `3cdd7eca1425f25769042ed0eb2274f97db6de40`, via three-stage streaming pipeline (`--mode stream` -> `--mode merge` -> `--mode build`).

The `reproduce.sh` script in this directory is a self-contained recipe: it clones the repo at the recorded commit, builds `rat_enum`, and runs the exact sequence of commands that produced the dataset.

Prerequisites: a recent Rust toolchain (stable, 2024-12 or later); `git`, a C linker, and `pkg-config` (the standard Cargo build deps).

```sh
bash tools/reproduce.sh
```

(The script honours `REPO`, `COMMIT`, and `SRC_DIR` environment variables for mirroring / vendoring / pre-cloned checkouts; see the script header.)

The reproduced directory must match the existing one file-for-file. If not, the most likely cause is a different Rust version producing a different state ordering inside the DAFSA -- pin to the toolchain version this commit's `Cargo.lock` specifies. For bit-identical `ro-crate-metadata.json` across reruns, set `SOURCE_DATE_EPOCH` to a fixed POSIX-seconds value before running:

```sh
SOURCE_DATE_EPOCH=1780000000 bash tools/reproduce.sh
```

Otherwise the `CreateAction.endTime` will reflect the current wall-clock time and the metadata hash will drift; the block files and `block_index.json` are unaffected.
