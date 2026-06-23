# machin-kv

A **persistent key-value store** written in **[machin](https://github.com/javimosch/machin)** (MFL), backed by **SQLite**. `set`/`get`/`del`/`list` keys in a database file that survives across runs. Single native binary (links libsqlite3).

Part of [**awesome-machin**](https://github.com/javimosch/awesome-machin) — the machin ecosystem.

## Why it exists (dogfooding)

machin had file I/O but no real **database storage**. Building a persistent KV store drove **SQLite** into machin as builtins (backed by `libsqlite3`, linked only when used):

```machin
db := sqlite_open("store.db")            // -> handle (":memory:" for in-memory)
sqlite_exec(db, "CREATE TABLE ...")      // run SQL with no result
rows := sqlite_query(db, "SELECT ...")   // -> JSON array of row objects
sqlite_close(db)
```

The query returns a **JSON array** — so it composes directly with `json_get`. machin-kv reads a value with `json_get(rows, ".[0].v")`, and lists by indexing `.[i].k`/`.[i].v` until they run out. SQLite + JSON + flags + string ops, all already in machin.

## Build

Needs the [machin](https://github.com/javimosch/machin) compiler with the SQLite builtins (v0.26.0+) on `PATH`, a C compiler, and **libsqlite3** (`apt install libsqlite3-dev`).

```bash
./build.sh                          # → ./machin-kv
MACHIN=~/ai/machin/machin ./build.sh
```

## Use

```bash
machin-kv set name machin
machin-kv get name              # -> machin
machin-kv list                  # -> name = machin
machin-kv del name
machin-kv -d /path/store.db set k v   # custom db file (default: kv.db)
```

Commands: `set <key> <value>` · `get <key>` (exit 1 if absent) · `del <key>` · `list`. Flag: `-d/--db <file>` (default `kv.db`) · `-h/--help`. The store persists in the db file between runs.

> Keys and values are passed as **bound parameters** (`sqlite_exec(db, "… VALUES(?, ?)", []string{k, v})`), so input is injection-safe — a value containing SQL is stored literally, never executed.

## Layout

```
machin-kv/
├── kv.src        # the store (MFL)
├── flags.src     # vendored flag parser (canonical copy in machin/framework/)
├── build.sh      # encode flags.src + kv.src → compile to native (-lsqlite3)
└── README.md
```
