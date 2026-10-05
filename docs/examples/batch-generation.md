# Batch Generation

Generate batches of random v4 and time-ordered v7 UUIDs.

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

    std.debug.print("=== Batch UUID Generation ===\n\n", .{});

    const count = 10;
    var buf: [36]u8 = undefined;

    std.debug.print("Generating {d} v4 UUIDs:\n", .{count});
    for (0..count) |i| {
        const id = try uuid.UUID.v4(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }

    std.debug.print("\nGenerating {d} v7 UUIDs (time-ordered):\n", .{count});
    for (0..count) |i| {
        const id = try uuid.UUID.v7Now(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }

    std.debug.print("\nv7 UUIDs are time-ordered, making them ideal for database primary keys.\n", .{});
}
```

## Run

```bash
zig build run-batch-generation
```

## Output

```text
=== Batch UUID Generation ===

Generating 10 v4 UUIDs:
   1. 2e62f132-56a8-470b-a5da-b9042956fc20
   2. 843b0271-48e2-455e-bafa-56cd17ad726a
   3. c0eaf0c2-2e04-4ccb-91ac-cdff78be3e80
   4. e64070a3-ac47-40b5-98c1-85c18540ad06
   5. c3ea6b8b-34b3-435e-beab-43c2b3a2a94b
   6. 18260ed6-bf0a-4b1c-9963-fbb45cc02c29
   7. 797a5f65-6220-44cc-af5a-225900e4efbb
   8. 8af379ed-0fde-44cf-b6ab-651a868afd31
   9. fb4d60e0-3f91-4a8e-a05c-0feee4308b49
  10. 4e334865-adcc-46d9-97e1-6ed8fe39376f

Generating 10 v7 UUIDs (time-ordered):
   1. 01a10ae8-370b-79bd-850f-02159d4ca63c
   2. 01a10ae8-370b-73a6-bfbd-434368b91847
   3. 01a10ae8-370b-7bbc-8513-af83e91f4fcf
   4. 01a10ae8-370b-7325-9fee-4f5c2eb54236
   5. 01a10ae8-370b-7637-9c9d-84e4e7aa8c31
   6. 01a10ae8-370b-7647-9367-9e239e367c2c
   7. 01a10ae8-370b-7a4d-b82c-169579ae0f7a
   8. 01a10ae8-370b-7880-8993-98420344a809
   9. 01a10ae8-370b-76af-92b2-c5bda42e2eb4
  10. 01a10ae8-370b-78f0-b2f2-b81af679928a

v7 UUIDs are time-ordered, making them ideal for database primary keys.
```

> [!NOTE]
> All UUID values above are freshly generated and differ on every run. The surrounding text is stable.
