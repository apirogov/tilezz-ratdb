#!/bin/sh
#
# Rebuild this dataset (tilezz-rat-zz4-n32-free) from source.
# Reproduction strategy: streaming pipeline (--mode stream + merge + build).
#
# Tested with the same tilezz commit that produced the original.
# Re-running this script in a clean directory should yield a
# directory whose contents match the recorded sha256s in
# ro-crate-metadata.json (see the verification snippet in
# README.md).
#
# For bit-identical ro-crate-metadata.json, set
# SOURCE_DATE_EPOCH to a fixed value before running -- otherwise
# CreateAction.endTime will drift, but the block files and
# block_index.json are unaffected.

set -eu

REPO="${REPO:-https://github.com/apirogov/tilezz}"
COMMIT="${COMMIT:-dd4fd140969d82adddc54331d4d652c1f72d45a6}"
SRC_DIR="${SRC_DIR:-tilezz-dd4fd140969d82adddc54331d4d652c1f72d45a6}"

if [ ! -d "$SRC_DIR/.git" ]; then
    git clone "$REPO" "$SRC_DIR"
fi
( cd "$SRC_DIR" && git fetch && git checkout "$COMMIT" && \
  cargo build --release --bin rat_enum --features cli )

# Run the reproduction step(s) relative to the source tree so the
# `./target/release/rat_enum` path resolves.
cd "$SRC_DIR"

./target/release/rat_enum --ring 4 -n 32 --free --oeis-a-number A266549 --mode stream --threads 16 -o tilezz-rat-zz4-n32-free-pipeline
./target/release/rat_enum --ring 4 -n 32 --free --oeis-a-number A266549 --mode merge -o tilezz-rat-zz4-n32-free-pipeline
./target/release/rat_enum --ring 4 -n 32 --free --oeis-a-number A266549 --mode build --target-block-bytes 1048576 -o tilezz-rat-zz4-n32-free-pipeline
mv tilezz-rat-zz4-n32-free-pipeline/dafsa tilezz-rat-zz4-n32-free
echo
echo "Reproduced asset: $(pwd)/tilezz-rat-zz4-n32-free"
echo "Compare against the recorded sha256s via the snippet in README.md."
