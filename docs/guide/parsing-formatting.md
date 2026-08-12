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
const canonical = id.encode(&buf);          // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

var upper_buf: [36]u8 = undefined;
const uppercase = id.encodeUppercase(&upper_buf); // XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

var compact_buf: [32]u8 = undefined;
const compact = id.encodeCompact(&compact_buf); // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

var braced_buf: [38]u8 = undefined;
const braced = id.encodeBraced(&braced_buf); // {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}

var urn_buf: [45]u8 = undefined;
const urn = id.encodeUrn(&urn_buf); // urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Writer API

Write to any `std.Io.Writer`:

```zig
var w: std.Io.Writer = .fixed(&buf);
try id.formatWriter(&w);
```

## Allocated String

```zig
const str = try id.toString(allocator);
defer allocator.free(str);
```
