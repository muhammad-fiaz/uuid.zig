# v7 Time-Ordered

Unix-epoch time-ordered v7 UUID generation, plus a custom-timestamp v7.

<VersionBadge version="7" />

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

    std.debug.print("=== UUID v7 (Time-Ordered) ===\n\n", .{});

    for (0..5) |_| {
        const id = try uuid.UUID.v7Now(io);
        var buf: [36]u8 = undefined;
        std.debug.print("{s}\n", .{id.encode(&buf)});
    }

    std.debug.print("\nCustom timestamp v7:\n", .{});
    const custom = uuid.UUID.v7(0x123456789ABC, 0x456, [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA });
    var buf: [36]u8 = undefined;
    std.debug.print("{s}\n", .{custom.encode(&buf)});
}
```

## Run

```bash
zig build run-v7-time-ordered
```

## Output

```text
=== UUID v7 (Time-Ordered) ===

01a10ae8-2f56-7954-833e-b930229cfebb
01a10ae8-2f56-7f12-a582-e3ec8e52c4ac
01a10ae8-2f56-7607-9221-3b38cc48a296
01a10ae8-2f56-7067-a1b5-52657ce8d267
01a10ae8-2f56-773b-906c-635d5bdd5924

Custom timestamp v7:
12345678-9abc-7456-9122-334455667788
```

> [!NOTE]
> The five `v7Now` values embed the current time plus fresh randomness, so they differ on every run. The custom-timestamp line is deterministic.
