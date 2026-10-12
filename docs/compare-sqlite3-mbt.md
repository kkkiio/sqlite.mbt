# Comparison with moonbit-community/sqlite3.mbt

[moonbit-community/sqlite3.mbt](https://github.com/moonbit-community/sqlite3.mbt) is the actively maintained, community-reviewed SQLite binding for MoonBit. We use it as the quality bar: before changing an FFI binding, resource lifecycle, or error behavior here, check how it handles the same SQLite API and follow it unless one of the [intentional differences](#intentional-differences) applies. If you diverge, say why in the commit message, and record lasting differences in this document.

Last compared against: `moonbit-community/sqlite3@0.2.3` (commit `1405639`, 2026-10-02, vendored SQLite 3.49.1).

```bash
gh repo clone moonbit-community/sqlite3.mbt /tmp/sqlite3.mbt -- --depth 1
```

## Where to look

- `dev.md` - design notes: resource lifetime, native FFI adapters, error capture.
- `internal/ffi/ffi_native.mbt` + `internal/ffi/stub.c` - FFI patterns: `#external` opaque handles; `#borrow` only on reference-counted params (`Bytes`, `Ref`, ...), never on `#external` types; bind directly to `sqlite3_*` when the ABI already matches and keep the C stub for real adaptation (copying strings/blobs into `moonbit_make_bytes`, reshaping open/prepare results).
- `error.mbt` - SQLite result codes as `SqliteError(code~, extended~, msg~)`. Our public API still returns `Bool` / `Option`; switching to raised errors is a breaking change (major version bump), so do not do it as a drive-by fix.
- `basic_test.mbt`, `stmt_test.mbt`, `value_test.mbt` - edge cases worth mirroring when touching the same area: copies of a connection/statement share closed/finalized state, empty vs NULL text/blob, value round trips, reset with/without clearing bindings, file-backed persistence after reopen.

## Intentional differences

Do not "fix" these toward the reference:

- **Link the system / user-provided libsqlite3** (`-lsqlite3`); never vendor `sqlite3.c`. This is the reason this module exists: users control compile-time features such as FTS5 through the library they link.
- **JS target via Node.js `node:sqlite`**; no wasm target and no async API.
- **Public API** (`Database`, `Statement`, `SqlValue`, low-level `sqlite_*` functions) is kept compatible with the original `mizchi/sqlite` so existing users can switch by changing the module name.
- **`Database::close` uses `sqlite3_close_v2`**: it returns `Unit`, so with unfinalized statements the connection becomes a zombie and is released when the last statement is finalized. The reference instead keeps a busy connection open and reports an error, which needs an error-returning `close`.

## Maintaining this document

When a change here is informed by the reference, or the reference changes in an area we mirror, update the relevant section and the "Last compared against" line.
