# Parsing Formats

Parse canonical, compact, braced, and URN inputs, then render every output format.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID Parsing & Formatting ===\n\n", .{});

    const canonical = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
    var buf: [36]u8 = undefined;
    std.debug.print("Canonical: {s}\n", .{canonical.encode(&buf)});

    const compact = try uuid.parseCompact("550e8400e29b41d4a716446655440000");
    std.debug.print("From compact: {s}\n", .{compact.encode(&buf)});

    const braced = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");
    std.debug.print("From braced: {s}\n", .{braced.encode(&buf)});

    const urn = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");
    std.debug.print("From URN: {s}\n", .{urn.encode(&buf)});

    std.debug.print("\nOutput formats:\n", .{});
    std.debug.print("  Canonical:  {s}\n", .{canonical.encode(&buf)});

    var upperBuf: [36]u8 = undefined;
    std.debug.print("  Uppercase:  {s}\n", .{canonical.encodeUppercase(&upperBuf)});

    var compactBuf: [32]u8 = undefined;
    std.debug.print("  Compact:    {s}\n", .{canonical.encodeCompact(&compactBuf)});

    var bracedBuf: [38]u8 = undefined;
    std.debug.print("  Braced:     {s}\n", .{canonical.encodeBraced(&bracedBuf)});

    var urnBuf: [45]u8 = undefined;
    std.debug.print("  URN:        {s}\n", .{canonical.encodeUrn(&urnBuf)});
}
```

## Run

```bash
zig build run-parsing-formats
```

## Output

```text
=== UUID Parsing & Formatting ===

Canonical: 550e8400-e29b-41d4-a716-446655440000
From compact: 550e8400-e29b-41d4-a716-446655440000
From braced: 550e8400-e29b-41d4-a716-446655440000
From URN: 550e8400-e29b-41d4-a716-446655440000

Output formats:
  Canonical:  550e8400-e29b-41d4-a716-446655440000
  Uppercase:  550E8400-E29B-41D4-A716-446655440000
  Compact:    550e8400e29b41d4a716446655440000
  Braced:     {550e8400-e29b-41d4-a716-446655440000}
  URN:        urn:uuid:550e8400-e29b-41d4-a716-446655440000
```
