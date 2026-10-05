# Hash Map

Use UUID values as `std.AutoHashMap` keys.

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

    std.debug.print("=== UUID in Hash Maps ===\n\n", .{});

    var map = std.AutoHashMap(uuid.UUID, []const u8).init(allocator);
    defer map.deinit();

    const userId = try uuid.UUID.v4(io);
    const sessionId = try uuid.UUID.v4(io);

    try map.put(userId, "user@example.com");
    try map.put(sessionId, "session_abc123");

    var buf: [36]u8 = undefined;
    std.debug.print("User ID: {s}\n", .{userId.encode(&buf)});
    std.debug.print("Session ID: {s}\n", .{sessionId.encode(&buf)});

    std.debug.print("\nLooking up userId...\n", .{});
    if (map.get(userId)) |email| {
        std.debug.print("  Found: {s}\n", .{email});
    }

    std.debug.print("\nAll entries:\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        std.debug.print("  {s} -> {s}\n", .{ entry.key_ptr.encode(&buf), entry.value_ptr.* });
    }
}
```

## Run

```bash
zig build run-hash-map
```

## Output

```text
=== UUID in Hash Maps ===

User ID: 0fecdd59-06a7-4194-9c1a-65b1a6559866
Session ID: eff07381-4834-4c99-9c67-51da30592094

Looking up userId...
  Found: user@example.com

All entries:
  eff07381-4834-4c99-9c67-51da30592094 -> session_abc123
  0fecdd59-06a7-4194-9c1a-65b1a6559866 -> user@example.com
```

> [!NOTE]
> Both UUIDs are freshly generated, so values and iteration order differ on every run.
