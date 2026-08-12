# Namespaces

The RFC 4122 namespace constants and their use with v3 and v5.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var buf: [36]u8 = undefined;

    std.debug.print("DNS:  {s}\n", .{uuid.Namespace.dns.encode(&buf)});
    std.debug.print("URL:  {s}\n", .{uuid.Namespace.url.encode(&buf)});
    std.debug.print("OID:  {s}\n", .{uuid.Namespace.oid.encode(&buf)});
    std.debug.print("X500: {s}\n", .{uuid.Namespace.x500.encode(&buf)});

    const id_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    const id_url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("v3 DNS: {s}\n", .{id_dns.encode(&buf)});
    std.debug.print("v3 URL: {s}\n", .{id_url.encode(&buf)});
}
```

## Run

```bash
zig build run-namespaces
```

## Notes

- `Namespace.dns`, `Namespace.url`, `Namespace.oid`, and `Namespace.x500` are provided as compile-time constants.
- The same name under different namespaces yields different UUIDs.
