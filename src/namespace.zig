//! RFC 4122 namespace UUIDs for deterministic v3/v5 generation.
//!
//! Namespaces are plain `UUID` values borrowed by the caller. No allocation,
//! I/O, or mutable state is involved; sharing them across threads is safe.

const std = @import("std");
const UUID = @import("core.zig").UUID;

/// Well-known namespace UUIDs assigned by RFC 4122.
pub const Namespace = struct {
    /// Name-string namespace for fully-qualified domain names.
    pub const dns: UUID = .{ .bytes = .{
        0x6b, 0xa7, 0xb8, 0x10, 0x9d, 0xad, 0x11, 0xd1,
        0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8,
    } };
    /// Name-string namespace for URLs.
    pub const url: UUID = .{ .bytes = .{
        0x6b, 0xa7, 0xb8, 0x11, 0x9d, 0xad, 0x11, 0xd1,
        0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8,
    } };
    /// Name-string namespace for ISO object identifiers (OIDs).
    pub const oid: UUID = .{ .bytes = .{
        0x6b, 0xa7, 0xb8, 0x12, 0x9d, 0xad, 0x11, 0xd1,
        0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8,
    } };
    /// Name-string namespace for X.500 distinguished names.
    pub const x500: UUID = .{ .bytes = .{
        0x6b, 0xa7, 0xb8, 0x14, 0x9d, 0xad, 0x11, 0xd1,
        0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8,
    } };
};

test "namespace dns" {
    const testing = std.testing;
    try testing.expectEqual(@as(usize, 16), Namespace.dns.bytes.len);
    try testing.expectEqual(.v1, Namespace.dns.version());
}

test "namespace url" {
    const testing = std.testing;
    try testing.expect(!Namespace.dns.eql(Namespace.url));
}

test "namespace oid" {
    const testing = std.testing;
    try testing.expect(!Namespace.dns.eql(Namespace.oid));
}

test "namespace x500" {
    const testing = std.testing;
    try testing.expect(!Namespace.dns.eql(Namespace.x500));
}

test "namespaces are distinct" {
    const testing = std.testing;
    const all = [_]UUID{ Namespace.dns, Namespace.url, Namespace.oid, Namespace.x500 };
    for (all, 0..) |a, i| {
        for (all, 0..) |b, j| {
            if (i == j) continue;
            try testing.expect(!a.eql(b));
        }
    }
}
