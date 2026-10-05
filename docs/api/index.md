# API Reference

Complete API reference for the `uuid.zig` library.

## Module Structure

```
src/
  uuid.zig       - Public API root (re-exports everything below)
  core.zig       - UUID struct
  version.zig    - Version enum
  variant.zig    - Variant enum
  namespace.zig  - Namespace constants
  parse.zig      - Parsing functions
  generator.zig  - Generator type
  errors.zig     - Error types
  hex.zig        - Hex conversion utilities
```

## Quick Reference

| Function | Description |
|----------|-------------|
| `uuid.UUID.v1(timestamp, clockSequence, node)` | Generate v1 UUID |
| `uuid.UUID.v3(namespace, name)` | Generate v3 UUID |
| `uuid.UUID.v4(io)` | Generate v4 UUID |
| `uuid.UUID.v5(namespace, name)` | Generate v5 UUID |
| `uuid.UUID.v6(timestamp, clockSequence, node)` | Generate v6 UUID |
| `uuid.UUID.v7(timestampMs, randA, randB)` | Generate v7 UUID |
| `uuid.UUID.v7Now(io)` | Generate v7 with current time |
| `uuid.UUID.v8(custom)` | Generate v8 UUID |
| `uuid.parse(input)` | Parse canonical UUID |
| `uuid.parseCompact(input)` | Parse compact UUID |
| `uuid.parseBraced(input)` | Parse braced UUID |
| `uuid.parseUrn(input)` | Parse URN UUID |
| `uuid.parseAll(inputs, allocator)` | Parse multiple UUIDs (caller owns result) |
| `uuid.parseMultiDelim(input, delimiter, allocator)` | Parse delimited UUIDs (caller owns result) |
| `id.encode(buf)` | Format to canonical |
| `id.encodeUppercase(buf)` | Format to uppercase |
| `id.encodeCompact(buf)` | Format to compact |
| `id.encodeBraced(buf)` | Format to braced |
| `id.encodeUrn(buf)` | Format to URN |
| `id.toStringAlloc(allocator)` | Allocate canonical string (caller owns result) |
| `id.eql(other)` | Equality check |
| `id.compare(other)` | Ordering comparison |
| `id.toBytes()` | Convert to bytes |
| `uuid.UUID.fromBytes(bytes)` | Create from bytes |
| `id.toU128()` | Convert to u128 |
| `uuid.UUID.fromU128(value)` | Create from u128 |
| `id.hash()` | Get hash value |
| `id.version()` | Get version |
| `id.variant()` | Get variant |
| `id.isNil()` | Check if nil |
