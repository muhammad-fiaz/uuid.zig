# UUID

The core UUID type.

## Definition

```zig
pub const UUID = struct {
    bytes: [16]u8,
    // ...
};
```

## Fields

| Field | Type | Description |
|-------|------|-------------|
| `bytes` | `[16]u8` | Raw 16-byte UUID representation |

## Constants

| Constant | Description |
|----------|-------------|
| `UUID.nil` | The zero UUID |
| `UUID.max` | The max UUID (`ffffffff-ffff-ffff-ffff-ffffffffffff`) |

## Methods

### Generation

| Method | Signature | Description |
|--------|-----------|-------------|
| `v1` | `(timestamp: u60, clock_seq: u14, node: [6]u8) UUID` | Time-based |
| `v3` | `(namespace: UUID, name: []const u8) UUID` | MD5 namespace |
| `v4` | `(io: Io) Io.RandomSecureError!UUID` | Random |
| `v5` | `(namespace: UUID, name: []const u8) UUID` | SHA-1 namespace |
| `v6` | `(timestamp: u60, clock_seq: u14, node: [6]u8) UUID` | Reordered time |
| `v7` | `(timestamp_ms: u48, rand_a: u12, rand_b: [10]u8) UUID` | Epoch time |
| `v7Now` | `(io: Io) Io.RandomSecureError!UUID` | v7 with current time |
| `v8` | `(custom: [16]u8) UUID` | Application-specific |

### Formatting

| Method | Signature | Description |
|--------|-----------|-------------|
| `encode` | `(self, buffer: []u8) []u8` | Canonical format |
| `encodeUppercase` | `(self, buffer: []u8) []u8` | Uppercase format |
| `encodeCompact` | `(self, buffer: []u8) []u8` | Compact format |
| `encodeBraced` | `(self, buffer: []u8) []u8` | Braced format |
| `encodeUrn` | `(self, buffer: []u8) []u8` | URN format |
| `formatWriter` | `(self, writer: *Io.Writer) Io.Writer.Error!void` | Write to writer |
| `toString` | `(self, allocator: Allocator) Allocator.Error![]u8` | Allocated string |

### Inspection

| Method | Signature | Description |
|--------|-----------|-------------|
| `version` | `(self) Version` | Get version |
| `variant` | `(self) Variant` | Get variant |
| `isNil` | `(self) bool` | Check if nil |
| `isMax` | `(self) bool` | Check if max UUID |
| `hash` | `(self) u64` | Get hash |

### Comparison

| Method | Signature | Description |
|--------|-----------|-------------|
| `eql` | `(self, other: UUID) bool` | Equality |
| `compare` | `(self, other: UUID) std.math.Order` | Ordering |

### Conversion

| Method | Signature | Description |
|--------|-----------|-------------|
| `toBytes` | `(self) [16]u8` | Convert to bytes |
| `fromBytes` | `(bytes: [16]u8) UUID` | Create from bytes (static) |
| `toU128` | `(self) u128` | Convert to u128 |
| `fromU128` | `(value: u128) UUID` | Create from u128 (static) |

### Hash Generation

| Method | Signature | Description |
|--------|-----------|-------------|
| `generateFromHash` | `(ver: Version, namespace: *const [16]u8, name: []const u8) UUID` | Hash-based generation |
