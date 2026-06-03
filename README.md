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
| `zz12-n10-free` | ZZ12, perimeter <= 10, free (OEIS A316192) | 16751 | `e40fd21a14165ffe1858da2f808f3663201bf26d` |

## License

All datasets: CC-BY-SA 4.0 (see each branch's README for the full
notice). Produced by [tilezz](https://github.com/apirogov/tilezz).
