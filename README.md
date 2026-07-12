# tilezz-ratdb

Rat polygon datasets ("RatDB") for the [tilezz](https://github.com/apirogov/tilezz)
web explorer, stored in the tilezz-rat-dafsa-blocks format.

## Layout

One dataset per orphan branch; `main` only holds this index. Each
dataset branch is a self-describing RO-Crate 1.2 asset: manifest
(`block_index.json`), `ro-crate-metadata.json`, schemas, tools,
README, and the content-addressed `blocks/<sha256>.bin` files.

The explorer fetches blocks lazily via
`https://raw.githubusercontent.com/apirogov/tilezz-ratdb/<commit>/blocks/<sha256>.bin`,
pinned to a commit so the served bytes are immutable.

## Datasets

| branch | dataset | sequences | source commit |
|---|---|---|---|
| `zz4-n32-free` | ZZ4, perimeter <= 32, free (OEIS A266549) | 435646127 | `dd4fd140969d82adddc54331d4d652c1f72d45a6` |
| `zz8-n20-free` | ZZ8, perimeter <= 20, free (OEIS A316198) | 2940554725 | `aea0104980c8742d828060ec03437c64b72afa18` |
| `zz6-n24-free` | ZZ6, perimeter <= 24, free (OEIS A284869) | 7099803810 | `aea0104980c8742d828060ec03437c64b72afa18` |
| `zz10-n18-free` | ZZ10, perimeter <= 18, free (OEIS A316200) | 2875831850 | `aea0104980c8742d828060ec03437c64b72afa18` |
| `zz12-n16-free` | ZZ12, perimeter <= 16, free (OEIS A316192) | 1696726440 | `aea0104980c8742d828060ec03437c64b72afa18` |
| `zz3-n39-free` | ZZ3 (ZZ6 step-2 subring), perimeter <= 39, free | 730680086 | `7b63a8895289033f229fb1e05815d1948f23983e` |
| `zz5-n25-free` | ZZ5 (ZZ10 step-2 subring), perimeter <= 25, free | 1699394169 | `7b63a8895289033f229fb1e05815d1948f23983e` |
| `zz7-n21-free` | ZZ7 (ZZ14 step-2 subring), perimeter <= 21, free | 1116823845 | `3cdd7eca1425f25769042ed0eb2274f97db6de40` |
| `zz9-n18-free` | ZZ9 (ZZ18 step-2 subring), perimeter <= 18, free | 503397962 | `3cdd7eca1425f25769042ed0eb2274f97db6de40` |

## Miscellaneous

Artifacts that are not rat-enumeration DAFSA datasets:

| branch | contents |
|---|---|
| `zz12-le14-certs` | Certified tiling verdict for every free ZZ12 tile of perimeter <= 14 (33,279,563 certs; P/N/U = 480,286 / 32,799,276 / 1). Each is proven cannot-tile (finite Heesch) or tiles periodically, EXCEPT one -- the spectre -- so this is a machine-checkable proof that the spectre is the minimal-perimeter chiral aperiodic ZZ12 monotile, unique at perimeter 14. Split gzip; see the branch README to reassemble and verify. |

## License

All datasets: CC-BY-SA 4.0 (see each branch's README for the full
notice). Produced by [tilezz](https://github.com/apirogov/tilezz).
