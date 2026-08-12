# Comparison

Compare, convert, and hash UUIDs.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    const id1 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id2 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id3 = uuid.UUID.v3(uuid.Namespace.dns, "other.com");

    var buf: [36]u8 = undefined;
    std.debug.print("id1: {s}\n", .{id1.encode(&buf)});
    std.debug.print("id2: {s}\n", .{id2.encode(&buf)});
    std.debug.print("id3: {s}\n", .{id3.encode(&buf)});

    std.debug.print("id1 == id2: {}\n", .{id1.eql(id2)});
    std.debug.print("id1 == id3: {}\n", .{id1.eql(id3)});
    std.debug.print("id1 compare id3: {}\n", .{id1.compare(id3)});

    // Byte conversion
    const bytes = id1.toBytes();
    const restored = uuid.UUID.fromBytes(bytes);
    std.debug.print("Restored: {s}\n", .{restored.encode(&buf)});
    std.debug.print("Equal: {}\n", .{id1.eql(restored)});

    // Hash
    std.debug.print("Hash: {d}\n", .{id1.hash()});
}
```

## Run

```bash
zig build run-comparison
```
