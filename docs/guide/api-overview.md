# API Overview

The `uuid.zig` public API re-exports all types and functions from its flat `src/` modules.

## Types

| Type | Description |
|------|-------------|
| `UUID` | Core UUID struct with 16-byte internal representation |
| `Version` | Enum: `.v1` through `.v8`, `.nil`, `.unknown` |
| `Variant` | Enum: `.ncs`, `.rfc`, `.microsoft`, `.future` |
| `Namespace` | RFC 4122 namespace constants (`.dns`, `.url`, `.oid`, `.x500`) |
| `ParseError` | Error set: `InvalidLength`, `InvalidFormat`, `InvalidCharacter` |
| `Generator` | Stateless factory borrowing an allocator and `std.Io` |

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
const id = uuid.UUID.v1(timestamp, clockSequence, node);

// v6 (reordered time-based)
const id = uuid.UUID.v6(timestamp, clockSequence, node);

// v7 (custom timestamp)
const id = uuid.UUID.v7(timestampMs, randA, randB);

// v8 (application-specific)
const id = uuid.UUID.v8(customBytes);
```

## Parse

```zig
const id = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
const id = try uuid.parseCompact("550e8400e29b41d4a716446655440000");
const id = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");
const id = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");

// Batch parse (caller owns the returned slice)
const ids = try uuid.parseAll(&inputs, allocator);
defer allocator.free(ids);

// Delimited parse (caller owns the returned slice)
const delimited = try uuid.parseMultiDelim("550e8400-e29b-41d4-a716-446655440000,6ba7b810-9dad-11d1-80b4-00c04fd430c8", ',', allocator);
defer allocator.free(delimited);
```

## Format

```zig
var buf: [36]u8 = undefined;
const canonical = id.encode(&buf);
const uppercase = id.encodeUppercase(&buf);

var compactBuf: [32]u8 = undefined;
const compact = id.encodeCompact(&compactBuf);

var bracedBuf: [38]u8 = undefined;
const braced = id.encodeBraced(&bracedBuf);

var urnBuf: [45]u8 = undefined;
const urn = id.encodeUrn(&urnBuf);
```

## Inspect

```zig
const version = id.version(); // .v4
const variant = id.variant(); // .rfc
const isNil = id.isNil(); // false
const isMax = id.isMax(); // false
```

## Compare

```zig
if (id1.eql(id2)) { ... }
const order = id1.compare(id2); // .lt, .eq, .gt
```

## Convert

```zig
const bytes = id.toBytes(); // [16]u8
const id = uuid.UUID.fromBytes(bytes);
const int = id.toU128(); // u128
const id = uuid.UUID.fromU128(int);
```

## Hash

```zig
const hashVal = id.hash(); // u64
```

## Generator

```zig
const gen = uuid.Generator.init(allocator, io);
const id = try gen.v4();
const str = try gen.toStringAlloc(id);
defer allocator.free(str);
```
