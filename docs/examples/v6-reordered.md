# v6 Reordered Time-Based

Reordered time-based v6 UUID generation.

<VersionBadge version="6" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    const timestamp: u60 = 0x123456789ABCDEF;
    const clock_seq: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    const id = uuid.UUID.v6(timestamp, clock_seq, node);
    var buf: [36]u8 = undefined;
    std.debug.print("v6 UUID: {s}\n", .{id.encode(&buf)});
    std.debug.print("Version: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});
}
```

## Run

```bash
zig build run-v6-reordered
```

## Notes

- v6 uses the same timestamp, clock sequence, and node inputs as v1, but reorders the time fields so UUIDs sort in timestamp order when compared lexicographically.
- This ordering property makes v6 well suited for database keys / indexes.
