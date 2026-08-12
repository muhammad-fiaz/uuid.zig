# Allocator and Io Model

`uuid.zig` follows Zig 0.16 conventions: one explicit allocator and one explicit `std.Io` instance for random UUID generation.

## Allocator Model

There is a single allocator type: `std.mem.Allocator`.

- **Allocation-free operations**: generation into an existing `UUID`, parsing, validation, comparison, equality, hashing, version/variant detection, nil detection, raw byte conversion, and fixed-buffer formatting never allocate.
- **Allocator-backed operations**: only APIs that return owned, dynamically sized data allocate. These use the allocator you supply through the `Generator`.

No hidden allocator is ever created. The library never deinitializes your allocator — it remains owned by the caller.

```zig
const gen = uuid.Generator.init(allocator, io);
const str = try gen.toString(id);
defer allocator.free(str); // caller frees, caller's allocator
```

There is no global allocator state, so the library is compatible with any custom allocator, including failing allocators for testing.

## Io Model

Random UUID generation uses Zig 0.16's `std.Io` model. You construct an `Io` instance once and pass it where secure randomness is required.

```zig
var threaded: std.Io.Threaded = .init(allocator, .{});
defer threaded.deinit();
const io = threaded.io();

const v4 = try uuid.UUID.v4(io);
const v7 = try uuid.UUID.v7Now(io);
```

- v4 and the random parts of v7 use `io.randomSecure` — cryptographically secure entropy.
- If secure entropy is unavailable, an explicit error is returned. There is never a silent fallback to timestamps, process state, or weak PRNGs.
- There is no hidden global I/O state.

## Error Handling

The public error surface is deliberately small.

`ParseError` covers parsing:

```zig
error{
    InvalidLength,
    InvalidFormat,
    InvalidCharacter,
}
```

Random generation returns `Io.RandomSecureError` (which includes `EntropyUnavailable`) so callers always know when secure entropy could not be obtained. Allocator-backed APIs return `Allocator.Error` (including `OutOfMemory`).
