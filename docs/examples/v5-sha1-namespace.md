# v5 SHA-1 Namespace

Deterministic v5 UUID generation with SHA-1 namespace hashing.

<VersionBadge version="5" />

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v5 (SHA-1 Namespace) ===\n\n", .{});

    var buf: [36]u8 = undefined;

    const idDns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{idDns.encode(&buf)});

    const idUrl = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{idUrl.encode(&buf)});

    const idOid = uuid.UUID.v5(uuid.Namespace.oid, "www.example.com");
    std.debug.print("OID + www.example.com: {s}\n", .{idOid.encode(&buf)});

    const idX500 = uuid.UUID.v5(uuid.Namespace.x500, "www.example.com");
    std.debug.print("X500 + www.example.com: {s}\n", .{idX500.encode(&buf)});

    std.debug.print("\nv3 vs v5 (same input, different hash algorithms):\n", .{});
    const v3Id = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const v5Id = uuid.UUID.v5(uuid.Namespace.dns, "example.com");
    std.debug.print("  v3: {s}\n", .{v3Id.encode(&buf)});
    std.debug.print("  v5: {s}\n", .{v5Id.encode(&buf)});
    std.debug.print("  Different: {}\n", .{!v3Id.eql(v5Id)});

    std.debug.print("\nVersion: {}, Variant: {}\n", .{ idDns.version(), idDns.variant() });
}
```

## Run

```bash
zig build run-v5-sha1-namespace
```

## Output

```text
=== UUID v5 (SHA-1 Namespace) ===

DNS + www.example.com: 2ed6657d-e927-568b-95e1-2665a8aea6a2
URL + www.example.com: b63cdfa4-3df9-568e-97ae-006c5b8fd652
OID + www.example.com: a5e87d3b-479e-52da-b98a-db251a851854
X500 + www.example.com: a1d3adb1-15b7-5395-a05f-9051a08769a2

v3 vs v5 (same input, different hash algorithms):
  v3: 9073926b-929f-31c2-abc9-fad77ae3e8eb
  v5: cfbff0d1-9375-5685-968c-48ce8b15ae17
  Different: true

Version: .v5, Variant: .rfc
```
