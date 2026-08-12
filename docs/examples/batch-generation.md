# Batch Generation

Batch generate v4 and v7 UUIDs.

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

    const count = 10;
    var buf: [36]u8 = undefined;

    for (0..count) |i| {
        const id = try uuid.UUID.v4(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }

    for (0..count) |i| {
        const id = try uuid.UUID.v7Now(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }
}
```

## Run

```bash
zig build run-batch-generation
```

## Notes

- v7 UUIDs are time-ordered, making them ideal for use as database primary keys.
