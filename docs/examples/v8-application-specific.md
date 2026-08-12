# v8 Application-Specific

Application-specific v8 UUID generation with a custom 16-byte payload.

<VersionBadge version="8" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var buf: [36]u8 = undefined;

    const custom1 = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
    const id1 = uuid.UUID.v8(custom1);
    std.debug.print("  {s}\n", .{id1.encode(&buf)});
    std.debug.print("  Version: {}, Variant: {}\n", .{ id1.version(), id1.variant() });

    const custom3 = [_]u8{0xFF} ** 16;
    const id3 = uuid.UUID.v8(custom3);
    std.debug.print("  {s}\n", .{id3.encode(&buf)});
}
```

## Run

```bash
zig build run-v8-application-specific
```

## Notes

- v8 sets the version (8) and RFC variant bits automatically while leaving the rest to callers.
- v8 payloads are application-specific and not universally interoperable; document your layout.
