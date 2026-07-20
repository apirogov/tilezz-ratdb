#!/bin/sh
#
# Verify the ZZ12 perimeter<=14 tiling-classification cert store against a
# pinned tilezz. Mirrors the DAFSA datasets' reproduce.sh: pin -> clone ->
# build -> provenance-guard -> run. The payload is `classify_tiles --verify`,
# which for each stored certificate does the following -- note the two verdicts
# are NOT symmetric:
#
#   * PERIODIC -- replays the `build` recipe into the fundamental domain (a
#     meta-tile of k base copies), turns `glue` into the placing isometries,
#     grows their orbit into a lattice, and gold-checks -- in exact ring
#     arithmetic -- that it tiles the plane gap- and overlap-free (the exact
#     identity covolume == #cosets * k * base-area forces covering multiplicity
#     exactly 1). This is a full, self-contained re-proof that the tile tiles.
#
#   * CANNOT-TILE -- replays the stored k-corona and confirms it surrounds the
#     tile k times, i.e. re-proves the LOWER bound Heesch >= k. It does NOT
#     re-run the exhaustion that proves Heesch is FINITE (that no (k+1)-corona
#     exists). That upper bound is co-NP (no compact witness -- confirming it
#     costs the same as the original search), so --verify trusts the cert's
#     `status:Finite` for it. To re-establish the cannot-tile proofs
#     INDEPENDENTLY you must RE-RUN the classification itself (`classify_tiles
#     --asset <dafsa> --perim <n> --store <fresh>` for each perimeter, then
#     diff against this store); --verify is the cheap re-check, not that re-run.
#
#   * COVERAGE -- every enumerated free ZZ12 tile of each perimeter <= 14 is
#     present exactly once, so the 480,286 / 32,799,276 / 1 split and the single
#     Undecided residue (the spectre, dafsa index 31434778) are real, not an
#     artifact of missing lines.
#
# So a clean --verify proves: every perimeter-<=14 free ZZ12 tile carries a
# verdict, every PERIODIC verdict is a re-proven periodic tiling, every
# CANNOT-TILE verdict has a genuine Heesch-k lower-bound witness (its finiteness
# trusted from the original exhaustive search), and exactly one tile -- the
# spectre -- is left Undecided.
#
# Trust root / scope (stated honestly -- this is NOT a clean-room, tilezz-free
# oracle like the DAFSA verify.rs):
#   * verification uses tilezz's trusted geometric kernel (exact integer / ring
#     arithmetic; no float decides a verdict). You are trusting that kernel,
#     not the (heuristic) search that FOUND each cert.
#   * single-chirality (rotations only, no reflections) and edge-to-edge, the
#     latter resting on the pipeline's edge-to-edge reduction theorem
#     (docs/math/edge-to-edge-reduction.md in tilezz; external review pending).
#   * CannotTile soundness and Periodic verification are both exact.
#
# Requirements: git, curl, tar, gunzip, a sha256 tool (sha256sum or shasum),
# a Rust toolchain (cargo), and ~5 GB free disk (the unpacked store is ~4.2 GB)
# plus time (the full 33M-cert replay is not instant).
#
# Override any of these via the environment.

set -eu

# --- config -----------------------------------------------------------------

# tilezz ref to verify AGAINST (a tag like v0.2.0, or a bare commit sha). Must
# be a commit that carries `classify_tiles --version` (the store's format was
# confirmed readable + verifiable at current main, which this release is cut
# from). Override via the env for a local checkout.
REPO="${REPO:-https://github.com/apirogov/tilezz}"
COMMIT="${COMMIT:-v0.2.0}"
SRC_DIR="${SRC_DIR:-tilezz-verify}"

# The DAFSA the certs index into: the free ZZ12 rat set. The cert store carries
# no coordinates -- each base tile's geometry is recovered from this asset by
# index -- so verification needs it. This is the zz12_n16_free pin (its index
# is identical to the certs' for perimeter <= 14).
ASSET_REPO="${ASSET_REPO:-apirogov/tilezz-ratdb}"
ASSET_REF="${ASSET_REF:-8d7943bcbe95f3120f65f5933e75c3f6c349eee3}"
ASSET_DIR="${ASSET_DIR:-zz12_n16_free}"

STORE="zz12_le14_certs.jsonl"

# recorded sha256s (see README.md)
SHA_AA="4b3c953d068b108e967b48a03e0438b0c23acc09ed06c7d47a3b38a52efccb10"
SHA_AB="d132b470a9257685335476e5773441fadc56577c9cd1947cb62ca15fea278589"
SHA_GZ="84dec4a859b36203eac8334a75956e39cf97d34cfb39ece9f1ab919f1199251a"

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    else shasum -a 256 "$1" | cut -d' ' -f1; fi
}
check() {
    got=$(sha256 "$1")
    if [ "$got" != "$2" ]; then
        echo "ERROR: sha256 mismatch for $1" >&2
        echo "       got  $got" >&2
        echo "       want $2" >&2
        exit 1
    fi
    echo "  ok  $1"
}

# --- 1. integrity-check + reassemble + decompress the split store -----------

echo "[1/4] checking + reassembling the split store ..."
check "${STORE}.gz.aa" "$SHA_AA"
check "${STORE}.gz.ab" "$SHA_AB"
cat "${STORE}.gz.aa" "${STORE}.gz.ab" > "${STORE}.gz"
check "${STORE}.gz" "$SHA_GZ"
gunzip -kf "${STORE}.gz"          # -> $STORE (~4.2 GB); keeps the .gz
echo "  unpacked $STORE"

# --- 2. fetch the pinned DAFSA asset (blocks included, for offline decode) --

if [ ! -f "${ASSET_DIR}/block_index.json" ]; then
    echo "[2/4] fetching DAFSA asset ${ASSET_REPO}@${ASSET_REF} ..."
    mkdir -p "$ASSET_DIR"
    curl -sfL "https://api.github.com/repos/${ASSET_REPO}/tarball/${ASSET_REF}" \
        | tar -xz -C "$ASSET_DIR" --strip-components=1
else
    echo "[2/4] DAFSA asset ${ASSET_DIR}/ already present -- reusing"
fi

# --- 3. build classify_tiles from the pinned tilezz + provenance guard ------

echo "[3/4] building classify_tiles from ${REPO}@${COMMIT} ..."
if [ ! -d "$SRC_DIR/.git" ]; then
    git clone "$REPO" "$SRC_DIR"
fi
( cd "$SRC_DIR" && git fetch --tags origin && git checkout --quiet "$COMMIT" && \
  cargo build --release --bin classify_tiles --features cli )

# The commit the pin resolves to (COMMIT may be a tag like v0.2.0 or a sha).
RESOLVED="$(cd "$SRC_DIR" && git rev-parse HEAD)"

# Refuse to verify with a mismatched binary (stale PATH pickup, build-cache
# mixup, dirty tree) -- the failure modes that silently corrupt provenance.
# --version reports the COMMIT SHA (TILEZZ_GIT_COMMIT), not the tag name, so
# match on the resolved sha.
SELF="$("$SRC_DIR/target/release/classify_tiles" --version)"
case "$SELF" in
    *"$RESOLVED"*) : ;;
    *) echo "ERROR: built classify_tiles reports [$SELF] but pin $COMMIT resolves" >&2
       echo "       to $RESOLVED. Refusing to verify with a mismatched/dirty binary." >&2
       exit 1 ;;
esac
echo "  built $SELF (pin $COMMIT)"

# --- 4. verify ---------------------------------------------------------------

echo "[4/4] replaying + coverage-checking every certificate (this takes a while) ..."
"$SRC_DIR/target/release/classify_tiles" \
    --asset "$ASSET_DIR" --verify --store "$STORE"

echo
echo "VERIFIED: the cert store is clean against ${REPO}@${COMMIT}."
echo "Point-query one tile, e.g. the spectre:"
echo "  $SRC_DIR/target/release/classify_tiles --asset $ASSET_DIR --lookup 31434778"
