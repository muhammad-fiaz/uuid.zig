# Hash Map

Use UUIDs as hash map keys.

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

    var map = std.AutoHashMap(uuid.UUID, []const u8).init(allocator);
    defer map.deinit();

    const user_id = try uuid.UUID.v4(io);
    const session_id = try uuid.UUID.v4(io);

    try map.put(user_id, "user@example.com");
    try map.put(session_id, "session_abc123");

    if (map.get(user_id)) |email| {
        std.debug.print("Found: {s}\n", .{email});
    }
}
```

## Run

```bash
zig build run-hash-map
```

## Notes

- `UUID` implements `hash()`, so it works directly as an `AutoHashMap` key without conversion to strings.
- Hashing operates on the raw 16-byte representation, with no allocation.
