# Format API

UUID formatting functions.

## Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode` | `(self: UUID, buffer: []u8) []u8` | Canonical lowercase |
| `encodeUppercase` | `(self: UUID, buffer: []u8) []u8` | Canonical uppercase |
| `encodeCompact` | `(self: UUID, buffer: []u8) []u8` | No dashes |
| `encodeBraced` | `(self: UUID, buffer: []u8) []u8` | Wrapped in braces |
| `encodeUrn` | `(self: UUID, buffer: []u8) []u8` | URN prefix |
| `format` | `(self: UUID, writer: *Io.Writer) Io.Writer.Error!void` | Write to writer |
| `toString` | `(self: UUID, allocator: Allocator) Allocator.Error![]u8` | Allocated string |

## Buffer Sizes

| Format | Buffer Size |
|--------|-------------|
| Canonical | 36 bytes |
| Uppercase | 36 bytes |
| Compact | 32 bytes |
| Braced | 38 bytes |
| URN | 45 bytes |

## Validation

Use `uuid.isValid(input)` to check if a string is a valid UUID format without parsing:

```zig
if (uuid.isValid("550e8400-e29b-41d4-a716-446655440000")) {
    // Valid format
}
```

Supports all formats: canonical, compact, braced, and URN.
