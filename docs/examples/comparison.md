# Comparison

Compare, convert, and hash UUID values.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID Comparison ===\n\n", .{});

    const id1 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id2 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id3 = uuid.UUID.v3(uuid.Namespace.dns, "other.com");

    var buf: [36]u8 = undefined;
    std.debug.print("id1: {s}\n", .{id1.encode(&buf)});
    std.debug.print("id2: {s}\n", .{id2.encode(&buf)});
    std.debug.print("id3: {s}\n", .{id3.encode(&buf)});

    std.debug.print("\nid1 == id2: {}\n", .{id1.eql(id2)});
    std.debug.print("id1 == id3: {}\n", .{id1.eql(id3)});

    std.debug.print("\nid1 compare id3: {}\n", .{id1.compare(id3)});

    std.debug.print("\nBytes: ", .{});
    const bytes = id1.toBytes();
    for (bytes) |b| {
        std.debug.print("{x:0>2} ", .{b});
    }
    std.debug.print("\n", .{});

    const restored = uuid.UUID.fromBytes(bytes);
    std.debug.print("Restored: {s}\n", .{restored.encode(&buf)});
    std.debug.print("Equal: {}\n", .{id1.eql(restored)});

    const intVal = id1.toU128();
    const fromInt = uuid.UUID.fromU128(intVal);
    std.debug.print("From u128: {s}\n", .{fromInt.encode(&buf)});
    std.debug.print("Hash: {d}\n", .{id1.hash()});
}
```

## Run

```bash
zig build run-comparison
```

## Output

```text
=== UUID Comparison ===

id1: 9073926b-929f-31c2-abc9-fad77ae3e8eb
id2: 9073926b-929f-31c2-abc9-fad77ae3e8eb
id3: 0cebe351-27e4-3489-a95d-bd2986bd0f26

id1 == id2: true
id1 == id3: false

id1 compare id3: .gt

Bytes: 90 73 92 6b 92 9f 31 c2 ab c9 fa d7 7a e3 e8 eb
Restored: 9073926b-929f-31c2-abc9-fad77ae3e8eb
Equal: true
From u128: 9073926b-929f-31c2-abc9-fad77ae3e8eb
Hash: 4612373732028453
```
