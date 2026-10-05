# v3 MD5 Namespace

Deterministic v3 UUID generation with MD5 namespace hashing.

<VersionBadge version="3" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v3 (MD5 Namespace) ===\n\n", .{});

    var buf: [36]u8 = undefined;

    const idDns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{idDns.encode(&buf)});

    const idUrl = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{idUrl.encode(&buf)});

    const idOid = uuid.UUID.v3(uuid.Namespace.oid, "www.example.com");
    std.debug.print("OID + www.example.com: {s}\n", .{idOid.encode(&buf)});

    const idX500 = uuid.UUID.v3(uuid.Namespace.x500, "www.example.com");
    std.debug.print("X500 + www.example.com: {s}\n", .{idX500.encode(&buf)});

    std.debug.print("\nDeterministic - same input produces same UUID:\n", .{});
    const id1 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id2 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    std.debug.print("  Same input: {} == {}\n", .{ id1.eql(id2), id1.eql(id2) });

    std.debug.print("\nDifferent inputs produce different UUIDs:\n", .{});
    const id3 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const id4 = uuid.UUID.v3(uuid.Namespace.dns, "other.com");
    std.debug.print("  Different input: {} == {}\n", .{ id3.eql(id4), id3.eql(id4) });

    std.debug.print("\nVersion: {}, Variant: {}\n", .{ id1.version(), id1.variant() });
}
```

## Run

```bash
zig build run-v3-md5-namespace
```

## Output

```text
=== UUID v3 (MD5 Namespace) ===

DNS + www.example.com: 5df41881-3aed-3515-88a7-2f4a814cf09e
URL + www.example.com: a777199a-c522-31c4-8f4b-335feec7215b
OID + www.example.com: c2c1e4de-6589-389e-9375-32a90c6a83a8
X500 + www.example.com: f4ea5e25-91d4-38b0-b74f-af6c57210cae

Deterministic - same input produces same UUID:
  Same input: true == true

Different inputs produce different UUIDs:
  Different input: false == false

Version: .v3, Variant: .rfc
```
