# AGENTS.md

Commands and conventions for working in this repo. 

## After any `grammar.js` change (mandatory)

```
make test                   # regen src/parser.c, src/grammar.json, src/node-types.json
                            # corpus — must stay green
git add src/ grammar.js     # src/ is committed (bindings build from it — never leave it drifted)
```

`src/parser.c`, `src/grammar.json`, `src/node-types.json` are **CHECKED IN** and
are the source of truth for every binding (C/Go/Node/Python all build from
`src/`). Regenerate and commit them on every grammar change — a drifted `src/`
will fail CI's `git diff --exit-code src/` gate.

## Binding tests

Run the ones you touched, or all four:

```
npm install && npm test                                       # Node  (node --test bindings/node/*_test.js)
go test ./bindings/go                                         # Go
pip install -e . && python -m pytest bindings/python/tests    # Python
make test                                                     # alias for `tree-sitter generate && tree-sitter test`
```

Node and Python bindings require a C compiler — `node-gyp` and `setuptools`
both compile `src/parser.c` into a native extension.

## Gotchas

- `\n` is deliberately NOT in `extras` (`grammar.js` line ~49) — it's what
  keeps `command_line` line-bound. Do NOT add it.
- New rich rules promote a leading keyword via `token(prec(2, "kw"))`. A
  GENERIC rule (`seq(kw, repeat(arg))`) is safe; a SPECIFIC rule orphans
  sibling commands because the lexer commits to the keyword tokenization and
  tree-sitter does NOT re-lex. See the deferred-`ip address` comment in
  `grammar.js` (~line 391): one specific rule regressed coverage by +344
  errors.
- Top-level commands dispatch via `_ios_statement`, NOT `_command`. A new
  top-level rich rule must be registered in BOTH (see the config-global /
  config-line / nacl mirrors, `grammar.js` ~line 290). Section-body rules go
  in `_command` only.
- Build artifacts (`*.a`, `*.so`, `*.dylib`, `*.wasm`, `*.pc`, `build/`,
  `node_modules/`, `dist/`, `*.egg-info`, `uv.lock`) are gitignored — never
  commit them.

## Where things live

- Grammar — `grammar.js`
- Generated parser — `src/` (`parser.c`, `grammar.json`, `node-types.json`)
- Bindings — `bindings/{c,go,node,python}/`
- Corpus — `test/corpus/*.txt` (153 cases, 13 files)
- Queries — `queries/` (`highlights.scm`, …)
