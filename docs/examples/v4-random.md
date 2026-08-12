# v4 Random

Generate cryptographically secure random UUIDs.

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

    for (0..5) |_| {
        const id = try uuid.UUID.v4(io);
        var buf: [36]u8 = undefined;
        std.debug.print("{s}\n", .{id.encode(&buf)});
    }
}
```

## Run

```bash
zig build run-v4-random
```
