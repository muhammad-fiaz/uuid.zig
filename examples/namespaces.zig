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
