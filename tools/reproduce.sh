#!/bin/sh
#
# Rebuild this dataset (tilezz-rat-zz8-n20-free) from source.
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
COMMIT="${COMMIT:-aea0104980c8742d828060ec03437c64b72afa18}"
SRC_DIR="${SRC_DIR:-tilezz-aea0104980c8742d828060ec03437c64b72afa18}"

# The recorded commit may carry a `-dirty` suffix (original built from
# an unclean tree); strip it for the checkout, but keep it for the
# provenance check so a dirty original is reported loudly.
BASE_COMMIT="${COMMIT%-dirty}"
if [ "$BASE_COMMIT" != "$COMMIT" ]; then
    echo "WARNING: recorded commit $COMMIT is marked -dirty -- the original was" >&2
    echo "         built from an unclean tree and may not reproduce exactly." >&2
fi

if [ ! -d "$SRC_DIR/.git" ]; then
    git clone "$REPO" "$SRC_DIR"
fi
( cd "$SRC_DIR" && git fetch && git checkout "$BASE_COMMIT" && \
  cargo build --release --bin rat_enum --features cli )

cd "$SRC_DIR"

# Provenance guard (paranoid): refuse to reproduce unless the binary we
# just built self-reports the expected commit. Catches a stale/wrong
# rat_enum picked up from PATH, a build-cache mixup, or a dirty tree --
# the failure modes that silently corrupt provenance.
SELF_VERSION="$(./target/release/rat_enum --version)"
case "$SELF_VERSION" in
    *"$BASE_COMMIT"*) : ;;
    *) echo "ERROR: built rat_enum reports [$SELF_VERSION] but this dataset was" >&2
       echo "       produced at commit $BASE_COMMIT. Refusing to reproduce with a" >&2
       echo "       mismatched binary." >&2
       exit 1 ;;
esac
case "$SELF_VERSION" in
    *-dirty*) echo "WARNING: rebuilt rat_enum is -dirty; output may not match exactly." >&2 ;;
esac

# Run the reproduction step(s) relative to the source tree so the
# `./target/release/rat_enum` path resolves.
./target/release/rat_enum --ring 8 -n 20 --free --oeis-a-number A316198 --mode stream --threads 16 -o tilezz-rat-zz8-n20-free-pipeline
./target/release/rat_enum --ring 8 -n 20 --free --oeis-a-number A316198 --mode merge -o tilezz-rat-zz8-n20-free-pipeline
./target/release/rat_enum --ring 8 -n 20 --free --oeis-a-number A316198 --mode build --target-block-bytes 4194304 -o tilezz-rat-zz8-n20-free-pipeline
mv tilezz-rat-zz8-n20-free-pipeline/dafsa tilezz-rat-zz8-n20-free
echo
echo "Reproduced asset: $(pwd)/tilezz-rat-zz8-n20-free"
echo "Compare against the recorded sha256s via the snippet in README.md."
