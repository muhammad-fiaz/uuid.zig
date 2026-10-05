# Namespaces

RFC 4122 namespace constants and their use with deterministic v3/v5 UUIDs.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID Namespace Constants ===\n\n", .{});

    var buf: [36]u8 = undefined;

    std.debug.print("DNS:  {s}\n", .{uuid.Namespace.dns.encode(&buf)});
    std.debug.print("URL:  {s}\n", .{uuid.Namespace.url.encode(&buf)});
    std.debug.print("OID:  {s}\n", .{uuid.Namespace.oid.encode(&buf)});
    std.debug.print("X500: {s}\n", .{uuid.Namespace.x500.encode(&buf)});

    std.debug.print("\nUsing namespaces with v3 (MD5):\n", .{});
    const idDns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    const idUrl = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("  DNS + www.example.com: {s}\n", .{idDns.encode(&buf)});
    std.debug.print("  URL + www.example.com: {s}\n", .{idUrl.encode(&buf)});

    std.debug.print("\nUsing namespaces with v5 (SHA-1):\n", .{});
    const id5Dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    const id5Url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("  DNS + www.example.com: {s}\n", .{id5Dns.encode(&buf)});
    std.debug.print("  URL + www.example.com: {s}\n", .{id5Url.encode(&buf)});
}
```

## Run

```bash
zig build run-namespaces
```

## Output

```text
=== UUID Namespace Constants ===

DNS:  6ba7b810-9dad-11d1-80b4-00c04fd430c8
URL:  6ba7b811-9dad-11d1-80b4-00c04fd430c8
OID:  6ba7b812-9dad-11d1-80b4-00c04fd430c8
X500: 6ba7b814-9dad-11d1-80b4-00c04fd430c8

Using namespaces with v3 (MD5):
  DNS + www.example.com: 5df41881-3aed-3515-88a7-2f4a814cf09e
  URL + www.example.com: a777199a-c522-31c4-8f4b-335feec7215b

Using namespaces with v5 (SHA-1):
  DNS + www.example.com: 2ed6657d-e927-568b-95e1-2665a8aea6a2
  URL + www.example.com: b63cdfa4-3df9-568e-97ae-006c5b8fd652
```
