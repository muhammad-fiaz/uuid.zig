const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v5 (SHA-1 Namespace) ===\n\n", .{});

    var buf: [36]u8 = undefined;

    const id_dns = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{id_dns.encode(&buf)});

    const id_url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{id_url.encode(&buf)});

    const id_oid = uuid.UUID.v5(uuid.Namespace.oid, "www.example.com");
    std.debug.print("OID + www.example.com: {s}\n", .{id_oid.encode(&buf)});

    const id_x500 = uuid.UUID.v5(uuid.Namespace.x500, "www.example.com");
    std.debug.print("X500 + www.example.com: {s}\n", .{id_x500.encode(&buf)});

    std.debug.print("\nv3 vs v5 (same input, different hash algorithms):\n", .{});
    const v3_id = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    const v5_id = uuid.UUID.v5(uuid.Namespace.dns, "example.com");
    std.debug.print("  v3: {s}\n", .{v3_id.encode(&buf)});
    std.debug.print("  v5: {s}\n", .{v5_id.encode(&buf)});
    std.debug.print("  Different: {}\n", .{!v3_id.eql(v5_id)});

    std.debug.print("\nVersion: {}, Variant: {}\n", .{ id_dns.version(), id_dns.variant() });
}
