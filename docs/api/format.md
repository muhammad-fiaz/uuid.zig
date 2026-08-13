# Format API

UUID formatting functions.

## Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode` | `(self: *const UUID, buffer: []u8) []u8` | Canonical lowercase |
| `encodeUppercase` | `(self: *const UUID, buffer: []u8) []u8` | Canonical uppercase |
| `encodeCompact` | `(self: *const UUID, buffer: []u8) []u8` | No dashes |
| `encodeBraced` | `(self: *const UUID, buffer: []u8) []u8` | Wrapped in braces |
| `encodeUrn` | `(self: *const UUID, buffer: []u8) []u8` | URN prefix |
| `format` | `(self: *const UUID, writer: *Io.Writer) Io.Writer.Error!void` | Write to writer |
| `toString` | `(self: *const UUID, allocator: Allocator) Allocator.Error![]u8` | Allocated string |

## Buffer Sizes

| Format | Buffer Size |
|--------|-------------|
| Canonical | 36 bytes |
| Uppercase | 36 bytes |
| Compact | 32 bytes |
| Braced | 38 bytes |
| URN | 45 bytes |
