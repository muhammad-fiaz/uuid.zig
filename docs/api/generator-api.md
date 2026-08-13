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
| `v1` | `(self, timestamp: u60, clock_seq: u14, node: [6]u8) UUID` | Generate v1 |
| `v3` | `(self, namespace: UUID, name: []const u8) UUID` | Generate v3 |
| `v4` | `(self) Io.RandomSecureError!UUID` | Generate v4 |
| `v5` | `(self, namespace: UUID, name: []const u8) UUID` | Generate v5 |
| `v6` | `(self, timestamp: u60, clock_seq: u14, node: [6]u8) UUID` | Generate v6 |
| `v7` | `(self) Io.RandomSecureError!UUID` | Generate v7 |
| `v7WithTimestamp` | `(self, timestamp_ms: u48, rand_a: u12, rand_b: [10]u8) UUID` | Generate v7 with custom timestamp |
| `v8` | `(self, custom: [16]u8) UUID` | Generate v8 |
| `toString` | `(self, uuid: UUID) Allocator.Error![]u8` | UUID to string |

## Example

```zig
const gen = uuid.Generator.init(allocator, io);
const id = try gen.v4();
const str = try gen.toString(id);
defer allocator.free(str);
```
