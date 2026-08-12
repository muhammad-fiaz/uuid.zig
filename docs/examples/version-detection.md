# Version Detection

Detect the version and variant of any UUID.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var buf: [36]u8 = undefined;

    const v1 = uuid.UUID.v1(0x123456789ABCDEF, 0x1234, [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    std.debug.print("v1: {s} (version: {}, variant: {})\n", .{ v1.encode(&buf), v1.version(), v1.variant() });

    const v3 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    std.debug.print("v3: {s} (version: {}, variant: {})\n", .{ v3.encode(&buf), v3.version(), v3.variant() });

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const v4 = try uuid.UUID.v4(io);
    std.debug.print("v4: {s} (version: {}, variant: {})\n", .{ v4.encode(&buf), v4.version(), v4.variant() });

    std.debug.print("nil: {s} (version: {}, isNil: {})\n", .{ uuid.UUID.nil.encode(&buf), uuid.UUID.nil.version(), uuid.UUID.nil.isNil() });
}
```

## Run

```bash
zig build run-version-detection
```

## Notes

- `version()` returns a `Version` enum (`v1`..`v8`, `nil`, `unknown`).
- `variant()` returns a `Variant` enum (`ncs`, `rfc`, `microsoft`, `future`).
