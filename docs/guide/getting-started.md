# Getting Started

`uuid.zig` is a production-ready UUID library for Zig 0.16.0. It provides generation, parsing, formatting, and comparison for all standard UUID versions.

## Quick Example

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    // Generate a random v4 UUID
    const id = try uuid.UUID.v4(io);
    var buf: [36]u8 = undefined;
    std.debug.print("UUID: {s}\n", .{id.encode(&buf)});

    // Parse a UUID string
    const parsed = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");

    // Compare
    if (id.eql(parsed)) {
        std.debug.print("Equal!\n", .{});
    }
}
```

## What You Can Do

- **Generate** UUIDs (v1, v3, v4, v5, v6, v7, v8)
- **Parse** UUID strings (canonical, compact, braced, URN)
- **Format** UUIDs to strings (canonical, uppercase, compact, braced, URN)
- **Compare** UUIDs (equality, ordering)
- **Convert** between bytes, u128, and string representations
- **Hash** UUIDs for use in hash maps

## Next Steps

- [Installation](/guide/installation) - Add uuid.zig to your project
- [API Overview](/guide/api-overview) - Learn the full API
- [UUID Versions](/guide/uuid-versions) - Understand each UUID version
