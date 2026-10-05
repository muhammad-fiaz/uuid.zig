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
