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

> [!NOTE]
> `Generator` borrows its allocator and `Io` without taking ownership. Both must outlive the generator. Sharing one instance across threads is safe when the borrowed allocator and `Io` permit concurrent use.

## Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `init` | `(allocator: Allocator, io: Io) Generator` | Create generator |
| `v1` | `(self, timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID` | Generate v1 |
| `v3` | `(self, namespace: UUID, name: []const u8) UUID` | Generate v3 |
| `v4` | `(self) Io.RandomSecureError!UUID` | Generate v4 |
| `v5` | `(self, namespace: UUID, name: []const u8) UUID` | Generate v5 |
| `v6` | `(self, timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID` | Generate v6 |
| `v7` | `(self) Io.RandomSecureError!UUID` | Generate v7 |
| `v7WithTimestamp` | `(self, timestampMs: u48, randA: u12, randB: [10]u8) UUID` | Generate v7 with custom timestamp |
| `v8` | `(self, custom: [16]u8) UUID` | Generate v8 |
| `toStringAlloc` | `(self, uuid: UUID) Allocator.Error![]u8` | UUID to owned string |

## Example

```zig
const gen = uuid.Generator.init(allocator, io);
const id = try gen.v4();
const str = try gen.toStringAlloc(id);
defer allocator.free(str);
```
