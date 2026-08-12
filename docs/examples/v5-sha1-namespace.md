# v5 SHA-1 Namespace

Deterministic v5 UUID generation via SHA-1 namespace hashing.

<VersionBadge version="5" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var buf: [36]u8 = undefined;

    const id_dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{id_dns.encode(&buf)});

    const id_url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{id_url.encode(&buf)});

    const v3_id = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const v5_id = uuid.UUID.v5(uuid.Namespace.dns, "example.com");
    std.debug.print("v3 and v5 differ: {}\n", .{!v3_id.eql(v5_id)});
}
```

## Run

```bash
zig build run-v5-sha1-namespace
```

## Notes

- v5 uses SHA-1 and mirrors the v3 API. Same namespace and name always yield the same UUID.
- v3 (MD5) and v5 (SHA-1) produce distinct UUIDs for identical input.
