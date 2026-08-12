# API Overview

The `uuid.zig` public API re-exports all types and functions from its modular internals.

## Types

| Type | Description |
|------|-------------|
| `UUID` | Core UUID struct with 16-byte internal representation |
| `Version` | Enum: `.v1` through `.v8`, `.nil`, `.unknown` |
| `Variant` | Enum: `.ncs`, `.rfc`, `.microsoft`, `.future` |
| `Namespace` | RFC 4122 namespace constants (`.dns`, `.url`, `.oid`, `.x500`) |
| `ParseError` | Error set: `InvalidLength`, `InvalidFormat`, `InvalidCharacter` |
| `Generator` | Allocator-aware wrapper for generation and string conversion |

## Generate

```zig
// v4 (random)
const id = try uuid.UUID.v4(io);

// v7 (time-ordered, random)
const id = try uuid.UUID.v7Now(io);

// v3 (deterministic, MD5)
const id = uuid.UUID.v3(uuid.Namespace.dns, "example.com");

// v5 (deterministic, SHA-1)
const id = uuid.UUID.v5(uuid.Namespace.dns, "example.com");

// v1 (time-based)
const id = uuid.UUID.v1(timestamp, clock_seq, node);

// v6 (reordered time-based)
const id = uuid.UUID.v6(timestamp, clock_seq, node);

// v7 (custom timestamp)
const id = uuid.UUID.v7(timestamp_ms, rand_a, rand_b);

// v8 (application-specific)
const id = uuid.UUID.v8(custom_bytes);
```

## Parse

```zig
const id = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
const id = try uuid.parseCompact("550e8400e29b41d4a716446655440000");
const id = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");
const id = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");
```

## Format

```zig
var buf: [36]u8 = undefined;
const canonical = id.encode(&buf);
const uppercase = id.encodeUppercase(&buf);

var compact_buf: [32]u8 = undefined;
const compact = id.encodeCompact(&compact_buf);

var braced_buf: [38]u8 = undefined;
const braced = id.encodeBraced(&braced_buf);

var urn_buf: [45]u8 = undefined;
const urn = id.encodeUrn(&urn_buf);
```

## Inspect

```zig
const version = id.version();   // .v4
const variant = id.variant();   // .rfc
const is_nil = id.isNil();      // false
```

## Compare

```zig
if (id1.eql(id2)) { ... }
const order = id1.compare(id2); // .lt, .eq, .gt
```

## Convert

```zig
const bytes = id.toBytes();      // [16]u8
const id = uuid.UUID.fromBytes(bytes);
const int = id.toU128();         // u128
const id = uuid.UUID.fromU128(int);
```

## Hash

```zig
const hash_val = id.hash(); // u64
```

## Generator

```zig
const gen = uuid.Generator.init(allocator, io);
const id = try gen.v4();
const str = try gen.toString(id);
defer allocator.free(str);
```
