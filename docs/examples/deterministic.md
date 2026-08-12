# Deterministic

Generate deterministic v3, v5, and v8 UUIDs.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    // v3 (MD5 namespace)
    const id3_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    const id3_url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    var buf: [36]u8 = undefined;
    std.debug.print("v3 DNS: {s}\n", .{id3_dns.encode(&buf)});
    std.debug.print("v3 URL: {s}\n", .{id3_url.encode(&buf)});

    // v5 (SHA-1 namespace)
    const id5_dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    std.debug.print("v5 DNS: {s}\n", .{id5_dns.encode(&buf)});

    // v8 (application-specific)
    const custom = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                          0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
    const id8 = uuid.UUID.v8(custom);
    std.debug.print("v8:    {s}\n", .{id8.encode(&buf)});
}
```

## Run

```bash
zig build run-deterministic
```
