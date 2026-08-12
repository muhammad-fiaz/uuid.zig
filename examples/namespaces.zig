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
    const id_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    const id_url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("  DNS + www.example.com: {s}\n", .{id_dns.encode(&buf)});
    std.debug.print("  URL + www.example.com: {s}\n", .{id_url.encode(&buf)});

    std.debug.print("\nUsing namespaces with v5 (SHA-1):\n", .{});
    const id5_dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    const id5_url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("  DNS + www.example.com: {s}\n", .{id5_dns.encode(&buf)});
    std.debug.print("  URL + www.example.com: {s}\n", .{id5_url.encode(&buf)});
}
