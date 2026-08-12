# v3 MD5 Namespace

Deterministic v3 UUID generation via MD5 namespace hashing.

<VersionBadge version="3" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var buf: [36]u8 = undefined;

    const id_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{id_dns.encode(&buf)});

    const id_url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{id_url.encode(&buf)});

    const id_oid = uuid.UUID.v3(uuid.Namespace.oid, "www.example.com");
    std.debug.print("OID + www.example.com: {s}\n", .{id_oid.encode(&buf)});

    const id_x500 = uuid.UUID.v3(uuid.Namespace.x500, "www.example.com");
    std.debug.print("X500 + www.example.com: {s}\n", .{id_x500.encode(&buf)});

    const id1 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id2 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    std.debug.print("Same input identical: {}\n", .{id1.eql(id2)});
}
```

## Run

```bash
zig build run-v3-md5-namespace
```

## Notes

- v3 is deterministic: the same namespace and name always produce the same UUID.
- Names may be arbitrary byte slices, not just UTF-8 strings. No allocation occurs.
