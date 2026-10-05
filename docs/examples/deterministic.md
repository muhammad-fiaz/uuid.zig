# Deterministic

Deterministic v3, v5, and v8 generation from namespaces and payloads.

## Code

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== Deterministic UUID Generation ===\n\n", .{});

    std.debug.print("v3 (MD5 namespace):\n", .{});
    const id3Dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    const id3Url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    var buf: [36]u8 = undefined;
    std.debug.print("  DNS: {s}\n", .{id3Dns.encode(&buf)});
    std.debug.print("  URL: {s}\n", .{id3Url.encode(&buf)});

    std.debug.print("\nv5 (SHA-1 namespace):\n", .{});
    const id5Dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    const id5Url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("  DNS: {s}\n", .{id5Dns.encode(&buf)});
    std.debug.print("  URL: {s}\n", .{id5Url.encode(&buf)});

    std.debug.print("\nv8 (application-specific):\n", .{});
    const custom = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
    const id8 = uuid.UUID.v8(custom);
    std.debug.print("  Custom: {s}\n", .{id8.encode(&buf)});
}
```

## Run

```bash
zig build run-deterministic
```

## Output

```text
=== Deterministic UUID Generation ===

v3 (MD5 namespace):
  DNS: 5df41881-3aed-3515-88a7-2f4a814cf09e
  URL: a777199a-c522-31c4-8f4b-335feec7215b

v5 (SHA-1 namespace):
  DNS: 2ed6657d-e927-568b-95e1-2665a8aea6a2
  URL: b63cdfa4-3df9-568e-97ae-006c5b8fd652

v8 (application-specific):
  Custom: 01020304-0506-8708-890a-0b0c0d0e0f10
```
