const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v3 (MD5 Namespace) ===\n\n", .{});

    var buf: [36]u8 = undefined;

    const id_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
    std.debug.print("DNS + www.example.com: {s}\n", .{id_dns.encode(&buf)});

    const id_url = uuid.UUID.v3(uuid.Namespace.url, "www.example.com");
    std.debug.print("URL + www.example.com: {s}\n", .{id_url.encode(&buf)});

    const id_oid = uuid.UUID.v3(uuid.Namespace.oid, "www.example.com");
    std.debug.print("OID + www.example.com: {s}\n", .{id_oid.encode(&buf)});

    const id_x500 = uuid.UUID.v3(uuid.Namespace.x500, "www.example.com");
    std.debug.print("X500 + www.example.com: {s}\n", .{id_x500.encode(&buf)});

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
