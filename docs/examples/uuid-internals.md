---
title: UUID Internals
description: DCE Security UUIDs, timestamp extraction, sorting, validation, and batch parsing
---

# UUID Internals

Production-ready UUID operations for enterprise applications.

## DCE Security (v2)

Generate v2 UUIDs for POSIX UID/GID and other DCE security identifiers:

```zig
// POSIX UID (domain=1)
const uid = uuid.UUID.v2(1, 1000, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });

// POSIX GID (domain=2)
const gid = uuid.UUID.v2(2, 500, .{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 });
```

## Timestamp Extraction

Extract timestamps from v1, v6, and v7 UUIDs:

```zig
const v1 = uuid.UUID.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
const ts = v1.timestampV1(); // u60

const v7 = uuid.UUID.v7(0x017F22E279B0, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
const ms = v7.timestampV7(); // u48 (milliseconds since Unix epoch)
```

## Component Decomposition

Extract clock sequence and node from v1/v6 UUIDs:

```zig
const id = uuid.UUID.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });

const clock = id.clockSeq(); // u14
const node = id.node();       // [6]u8
```

## Sorting

Sort UUIDs in-place for database ordering:

```zig
var ids = [_]uuid.UUID{
    uuid.UUID.v3(uuid.Namespace.dns, "charlie.com"),
    uuid.UUID.v3(uuid.Namespace.dns, "alice.com"),
    uuid.UUID.v3(uuid.Namespace.dns, "bob.com"),
};
uuid.UUID.sort(&ids);
// ids is now sorted: alice, bob, charlie
```

## Validation

Check UUID format without parsing:

```zig
if (uuid.isValid("550e8400-e29b-41d4-a716-446655440000")) {
    // Valid format
}

uuid.isValid("550e8400e29b41d4a716446655440000"); // true (compact)
uuid.isValid("{550e8400-e29b-41d4-a716-446655440000}"); // true (braced)
uuid.isValid("urn:uuid:550e8400-e29b-41d4-a716-446655440000"); // true (URN)
uuid.isValid("not-a-uuid"); // false
```

## Batch Parsing

Parse multiple UUIDs at once:

```zig
const inputs = [_][]const u8{
    "550e8400-e29b-41d4-a716-446655440000",
    "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
};
const ids = try uuid.parseAll(&inputs, allocator);
defer allocator.free(ids);
```
