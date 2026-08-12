# v1 Time-Based

Time-based v1 UUID generation with an explicit timestamp, clock sequence, and node identifier.

<VersionBadge version="1" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    const timestamp: u60 = 0x123456789ABCDEF;
    const clock_seq: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    const id = uuid.UUID.v1(timestamp, clock_seq, node);
    var buf: [36]u8 = undefined;
    std.debug.print("v1 UUID: {s}\n", .{id.encode(&buf)});
    std.debug.print("Version: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});
}
```

## Run

```bash
zig build run-v1-time-based
```

## Notes

- The timestamp is the number of 100-nanosecond intervals since 1582-10-15 (UUID epoch).
- Node and clock sequence are fully customizable, so no machine-specific information is exposed by default.
