# Parsing & Formats

Parse and encode UUIDs in all supported formats.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    const canonical = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
    var buf: [36]u8 = undefined;

    // Output formats
    std.debug.print("Canonical: {s}\n", .{canonical.encode(&buf)});

    var upper_buf: [36]u8 = undefined;
    std.debug.print("Uppercase: {s}\n", .{canonical.encodeUppercase(&upper_buf)});

    var compact_buf: [32]u8 = undefined;
    std.debug.print("Compact:   {s}\n", .{canonical.encodeCompact(&compact_buf)});

    var braced_buf: [38]u8 = undefined;
    std.debug.print("Braced:    {s}\n", .{canonical.encodeBraced(&braced_buf)});

    var urn_buf: [45]u8 = undefined;
    std.debug.print("URN:       {s}\n", .{canonical.encodeUrn(&urn_buf)});
}
```

## Run

```bash
zig build run-parsing-formats
```
