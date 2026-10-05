# Parsing & Formatting

## Parsing

Parse UUIDs from four supported formats:

```zig
// Canonical: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
const id = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");

// Compact: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
const id = try uuid.parseCompact("550e8400e29b41d4a716446655440000");

// Braced: {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}
const id = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");

// URN: urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
const id = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");
```

> [!TIP]
> Use `uuid.parseAll` for batches and `uuid.parseMultiDelim` for delimited lists. Both return caller-owned slices — free them with the same allocator.

## Parse Errors

| Error | Cause |
|-------|-------|
| `InvalidLength` | Input string is wrong length |
| `InvalidFormat` | Missing or misplaced dashes |
| `InvalidCharacter` | Non-hex character in UUID |

## Formatting

Encode UUIDs to caller-provided buffers:

```zig
var buf: [36]u8 = undefined;
const canonical = id.encode(&buf); // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

var upperBuf: [36]u8 = undefined;
const uppercase = id.encodeUppercase(&upperBuf); // XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

var compactBuf: [32]u8 = undefined;
const compact = id.encodeCompact(&compactBuf); // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

var bracedBuf: [38]u8 = undefined;
const braced = id.encodeBraced(&bracedBuf); // {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}

var urnBuf: [45]u8 = undefined;
const urn = id.encodeUrn(&urnBuf); // urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Writer API

Write to any `std.Io.Writer`:

```zig
var w: std.Io.Writer = .fixed(&buf);
try id.format(&w);
```

## Allocated String

```zig
const str = try id.toStringAlloc(allocator);
defer allocator.free(str);
```
