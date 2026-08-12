# Basic Usage

Generate, parse, and inspect UUIDs.

## Code

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

    // Generate v4 UUID
    const id = try uuid.UUID.v4(io);
    var buf: [36]u8 = undefined;
    std.debug.print("Generated UUID: {s}\n", .{id.encode(&buf)});

    // Parse UUID
    const parsed = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
    var buf2: [36]u8 = undefined;
    std.debug.print("Parsed UUID:    {s}\n", .{parsed.encode(&buf2)});

    // Inspect
    std.debug.print("Version: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});
    std.debug.print("Is nil: {}\n", .{id.isNil()});

    // Nil UUID
    var nil_buf: [36]u8 = undefined;
    std.debug.print("Nil UUID: {s}\n", .{uuid.UUID.nil.encode(&nil_buf)});
}
```

## Run

```bash
zig build run-basic-usage
```
