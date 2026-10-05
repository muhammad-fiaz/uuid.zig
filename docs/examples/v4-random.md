# v4 Random

Generate cryptographically secure random v4 UUIDs with `std.Io.randomSecure`.

<VersionBadge version="4" />

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

    std.debug.print("=== UUID v4 (Random) ===\n\n", .{});

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

## Output

```text
=== UUID v4 (Random) ===

1e3a372e-6c4f-4582-8ae5-228ac5653c05
5da8ee7d-09b5-4257-8f12-35b1039622ef
c30eeb58-9f53-4f5d-9149-9950550bac1e
bb4c6b58-b24e-4943-98f9-3d7cf36fc116
efb24d64-3a97-4b7f-9b52-94fbc32c3e64
```

> [!NOTE]
> Every v4 UUID is freshly generated, so values differ on every run. Each line always reports version `.v4` and variant `.rfc`.
