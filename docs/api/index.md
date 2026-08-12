# API Reference

Complete API reference for the `uuid.zig` library.

## Module Structure

```
uuid.zig (public API)
  uuid/
    version.zig    - Version enum
    variant.zig    - Variant enum
    core.zig       - UUID struct
    namespace.zig  - Namespace constants
    parse.zig      - Parsing functions
    format.zig     - Formatting functions
    generator.zig  - Generator type
    errors.zig     - Error types
    hex.zig        - Hex conversion utilities
```

## Quick Reference

| Function | Description |
|----------|-------------|
| `uuid.UUID.v1(timestamp, clock_seq, node)` | Generate v1 UUID |
| `uuid.UUID.v3(namespace, name)` | Generate v3 UUID |
| `uuid.UUID.v4(io)` | Generate v4 UUID |
| `uuid.UUID.v5(namespace, name)` | Generate v5 UUID |
| `uuid.UUID.v6(timestamp, clock_seq, node)` | Generate v6 UUID |
| `uuid.UUID.v7(timestamp_ms, rand_a, rand_b)` | Generate v7 UUID |
| `uuid.UUID.v7Now(io)` | Generate v7 with current time |
| `uuid.UUID.v8(custom)` | Generate v8 UUID |
| `uuid.parse(input)` | Parse canonical UUID |
| `uuid.parseCompact(input)` | Parse compact UUID |
| `uuid.parseBraced(input)` | Parse braced UUID |
| `uuid.parseUrn(input)` | Parse URN UUID |
| `id.encode(buf)` | Format to canonical |
| `id.encodeUppercase(buf)` | Format to uppercase |
| `id.encodeCompact(buf)` | Format to compact |
| `id.encodeBraced(buf)` | Format to braced |
| `id.encodeUrn(buf)` | Format to URN |
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
