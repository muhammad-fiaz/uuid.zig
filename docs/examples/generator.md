# Generator

Use the Generator with allocator.

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

    const gen = uuid.Generator.init(allocator, io);

    const id1 = try gen.v4();
    var buf: [36]u8 = undefined;
    std.debug.print("v4: {s}\n", .{id1.encode(&buf)});

    const id2 = try gen.v7();
    std.debug.print("v7: {s}\n", .{id2.encode(&buf)});

    const str = try gen.toString(id1);
    defer allocator.free(str);
    std.debug.print("Allocated: {s}\n", .{str});
}
```

## Run

```bash
zig build run-generator
```
