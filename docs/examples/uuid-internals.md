---
title: UUID Internals
description: DCE Security UUIDs, timestamp extraction, sorting, validation, and batch parsing
---

# UUID Internals

Timestamp extraction, sorting, validation, and batch parsing in one runnable program.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    std.debug.print("=== UUID Internals ===\n\n", .{});

    // v2 - DCE Security (POSIX UID/GID)
    std.debug.print("--- v2 (DCE Security) ---\n", .{});
    const posixUid = uuid.UUID.v2(1, 1000, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    var buf: [36]u8 = undefined;
    std.debug.print("POSIX UID (domain=1, id=1000): {s}\n", .{posixUid.encode(&buf)});
    std.debug.print("Version: {}, Variant: {}\n\n", .{ posixUid.version(), posixUid.variant() });

    // Timestamp extraction
    std.debug.print("--- Timestamp Extraction ---\n", .{});
    const v1 = uuid.UUID.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    std.debug.print("v1 UUID: {s}\n", .{v1.encode(&buf)});
    std.debug.print("  Timestamp: 0x{X}\n", .{v1.timestampV1()});
    std.debug.print("  ClockSeq: 0x{X}\n", .{v1.clockSeq()});
    std.debug.print("  Node: ", .{});
    for (v1.node()) |b| {
        std.debug.print("{X:0>2} ", .{b});
    }
    std.debug.print("\n\n", .{});

    const v7 = uuid.UUID.v7(0x017F22E279B0, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
    std.debug.print("v7 UUID: {s}\n", .{v7.encode(&buf)});
    std.debug.print("  Timestamp (ms): 0x{X}\n\n", .{v7.timestampV7()});

    // Sorting
    std.debug.print("--- Sorting UUIDs ---\n", .{});
    var ids = [_]uuid.UUID{
        uuid.UUID.v3(uuid.Namespace.dns, "charlie.com"),
        uuid.UUID.v3(uuid.Namespace.dns, "alice.com"),
        uuid.UUID.v3(uuid.Namespace.dns, "bob.com"),
    };
    uuid.UUID.sort(&ids);
    for (ids) |id| {
        std.debug.print("  {s}\n", .{id.encode(&buf)});
    }

    // Validation
    std.debug.print("\n--- UUID Validation ---\n", .{});
    const validInputs = [_][]const u8{
        "550e8400-e29b-41d4-a716-446655440000",
        "550e8400e29b41d4a716446655440000",
        "{550e8400-e29b-41d4-a716-446655440000}",
        "urn:uuid:550e8400-e29b-41d4-a716-446655440000",
    };
    for (validInputs) |input| {
        std.debug.print("  \"{s}\" -> {}\n", .{ input, uuid.isValid(input) });
    }

    const invalidInputs = [_][]const u8{
        "not-a-uuid",
        "550e8400-e29b-41d4-a716",
        "550e8400-e29b-41d4-a716-446655440000-extra",
    };
    for (invalidInputs) |input| {
        std.debug.print("  \"{s}\" -> {}\n", .{ input, uuid.isValid(input) });
    }

    // Batch parsing
    std.debug.print("\n--- Batch Parsing ---\n", .{});
    const inputs = [_][]const u8{
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    };
    const parsed = try uuid.parseAll(&inputs, gpa.allocator());
    defer gpa.allocator().free(parsed);
    for (parsed) |id| {
        std.debug.print("  {s}\n", .{id.encode(&buf)});
    }
}
```

## Run

```bash
zig build run-uuid-internals
```

## Output

```text
=== UUID Internals ===

--- v2 (DCE Security) ---
POSIX UID (domain=1, id=1000): 00000000-0000-23e8-8100-aabbccddeeff
Version: .v2, Variant: .rfc

--- Timestamp Extraction ---
v1 UUID: c232ab00-9414-11ec-b3c8-9f6bdec741fb
  Timestamp: 0x1EC9414C232AB00
  ClockSeq: 0x33C8
  Node: 9F 6B DE C7 41 FB

v7 UUID: 017f22e2-79b0-7cc3-98c4-dc0c0c07398f
  Timestamp (ms): 0x17F22E279B0

--- Sorting UUIDs ---
  40ff909d-0c2b-3e28-9a11-0196e1e4c8fa
  c390c7cf-8f51-38c3-a144-8383bc41399c
  d78fe98c-ac0d-3409-91fb-c578cbc937be

--- UUID Validation ---
  "550e8400-e29b-41d4-a716-446655440000" -> true
  "550e8400e29b41d4a716446655440000" -> true
  "{550e8400-e29b-41d4-a716-446655440000}" -> true
  "urn:uuid:550e8400-e29b-41d4-a716-446655440000" -> true
  "not-a-uuid" -> false
  "550e8400-e29b-41d4-a716" -> false
  "550e8400-e29b-41d4-a716-446655440000-extra" -> false

--- Batch Parsing ---
  550e8400-e29b-41d4-a716-446655440000
  6ba7b810-9dad-11d1-80b4-00c04fd430c8
  6ba7b811-9dad-11d1-80b4-00c04fd430c8
```

## Notes

- `v2` encodes a DCE Security domain, local identifier, and node.
- `timestampV1`, `timestampV6`, and `timestampV7` round-trip the values passed to `v1`, `v6`, and `v7`.
- `UUID.sort` orders values lexicographically by their raw bytes.
- `parseAll` returns a caller-owned slice; free it with the same allocator.
