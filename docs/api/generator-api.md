# Generator API

Allocator-aware wrapper for UUID operations.

## Definition

```zig
pub const Generator = struct {
    allocator: Allocator,
    io: Io,
    // ...
};
```

## Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `init` | `(allocator: Allocator, io: Io) Generator` | Create generator |
| `v4` | `(self) Io.RandomSecureError!UUID` | Generate v4 |
| `v7` | `(self) Io.RandomSecureError!UUID` | Generate v7 |
| `toString` | `(self, uuid: UUID) Allocator.Error![]u8` | UUID to string |

## Example

```zig
const gen = uuid.Generator.init(allocator, io);
const id = try gen.v4();
const str = try gen.toString(id);
defer allocator.free(str);
```
