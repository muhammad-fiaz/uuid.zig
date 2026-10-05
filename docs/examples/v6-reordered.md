# v6 Reordered

Reordered time-based v6 UUID generation.

<VersionBadge version="6" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v6 (Reordered Time-Based) ===\n\n", .{});

    const timestamp: u60 = 0x123456789ABCDEF;
    const clockSequence: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    const id = uuid.UUID.v6(timestamp, clockSequence, node);
    var buf: [36]u8 = undefined;
    std.debug.print("v6 UUID: {s}\n", .{id.encode(&buf)});
    std.debug.print("Version: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});

    std.debug.print("\nv6 is like v1 but with reordered time fields for better database indexing.\n", .{});
}
```

## Run

```bash
zig build run-v6-reordered
```

## Output

```text
=== UUID v6 (Reordered Time-Based) ===

v6 UUID: 12345678-9abc-6def-9234-aabbccddeeff
Version: .v6
Variant: .rfc

v6 is like v1 but with reordered time fields for better database indexing.
```

## Notes

- v6 uses the same timestamp, clock sequence, and node inputs as v1, but reorders the time fields so UUIDs sort in timestamp order when compared lexicographically.
- This ordering property makes v6 well suited for database keys / indexes.
