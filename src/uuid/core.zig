const std = @import("std");
const Version = @import("version.zig").Version;
const Variant = @import("variant.zig").Variant;

pub const UUID = struct {
    bytes: [16]u8,

    pub const nil: UUID = .{ .bytes = [_]u8{0} ** 16 };

    pub const max: UUID = .{ .bytes = [_]u8{0xFF} ** 16 };

    pub fn isNil(self: UUID) bool {
        return self.eql(nil);
    }

    pub fn isMax(self: UUID) bool {
        return self.eql(max);
    }

    pub fn version(self: UUID) Version {
        const v = (self.bytes[6] >> 4) & 0x0F;
        return switch (v) {
            0 => if (self.isNil()) .nil else .unknown,
            1 => .v1,
            2 => .v2,
            3 => .v3,
            4 => .v4,
            5 => .v5,
            6 => .v6,
            7 => .v7,
            8 => .v8,
            else => .unknown,
        };
    }

    pub fn variant(self: UUID) Variant {
        return Variant.fromByte(self.bytes[8]);
    }

    pub fn eql(self: UUID, other: UUID) bool {
        return std.mem.eql(u8, &self.bytes, &other.bytes);
    }

    pub fn compare(self: UUID, other: UUID) std.math.Order {
        for (self.bytes, other.bytes) |a, b| {
            if (a < b) return .lt;
            if (a > b) return .gt;
        }
        return .eq;
    }

    pub fn toBytes(self: UUID) [16]u8 {
        return self.bytes;
    }

    pub fn fromBytes(bytes: [16]u8) UUID {
        return .{ .bytes = bytes };
    }

    pub fn toU128(self: UUID) u128 {
        return @as(u128, @bitCast(self.bytes));
    }

    pub fn fromU128(value: u128) UUID {
        return .{ .bytes = @bitCast(value) };
    }

    pub fn hash(self: UUID) u64 {
        return std.hash.Wyhash.hash(0, &self.bytes);
    }

    pub fn v1(timestamp: u60, clock_seq: u14, node_id: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestamp >> 24) & 0xFF);
        bytes[1] = @truncate((timestamp >> 16) & 0xFF);
        bytes[2] = @truncate((timestamp >> 8) & 0xFF);
        bytes[3] = @truncate(timestamp & 0xFF);

        bytes[4] = @truncate((timestamp >> 40) & 0xFF);
        bytes[5] = @truncate((timestamp >> 32) & 0xFF);

        bytes[6] = 0x10 | @as(u8, @truncate((timestamp >> 56) & 0x0F));
        bytes[7] = @truncate((timestamp >> 48) & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate((clock_seq >> 8) & 0x3F));
        bytes[9] = @truncate(clock_seq & 0xFF);

        bytes[10] = node_id[0];
        bytes[11] = node_id[1];
        bytes[12] = node_id[2];
        bytes[13] = node_id[3];
        bytes[14] = node_id[4];
        bytes[15] = node_id[5];

        return .{ .bytes = bytes };
    }

    pub fn v3(namespace: UUID, name: []const u8) UUID {
        return generateFromHash(.v3, &namespace.bytes, name);
    }

    pub fn v4(io: std.Io) std.Io.RandomSecureError!UUID {
        var bytes: [16]u8 = undefined;
        try io.randomSecure(&bytes);
        bytes[6] = 0x40 | (bytes[6] & 0x0F);
        bytes[8] = 0x80 | (bytes[8] & 0x3F);
        return .{ .bytes = bytes };
    }

    pub fn v5(namespace: UUID, name: []const u8) UUID {
        return generateFromHash(.v5, &namespace.bytes, name);
    }

    pub fn v6(timestamp: u60, clock_seq: u14, node_id: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestamp >> 52) & 0xFF);
        bytes[1] = @truncate((timestamp >> 44) & 0xFF);
        bytes[2] = @truncate((timestamp >> 36) & 0xFF);
        bytes[3] = @truncate((timestamp >> 28) & 0xFF);
        bytes[4] = @truncate((timestamp >> 20) & 0xFF);
        bytes[5] = @truncate((timestamp >> 12) & 0xFF);

        bytes[6] = 0x60 | @as(u8, @truncate((timestamp >> 8) & 0x0F));
        bytes[7] = @truncate(timestamp & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate((clock_seq >> 8) & 0x3F));
        bytes[9] = @truncate(clock_seq & 0xFF);

        bytes[10] = node_id[0];
        bytes[11] = node_id[1];
        bytes[12] = node_id[2];
        bytes[13] = node_id[3];
        bytes[14] = node_id[4];
        bytes[15] = node_id[5];

        return .{ .bytes = bytes };
    }

    pub fn v7(timestamp_ms: u48, rand_a: u12, rand_b: [10]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestamp_ms >> 40) & 0xFF);
        bytes[1] = @truncate((timestamp_ms >> 32) & 0xFF);
        bytes[2] = @truncate((timestamp_ms >> 24) & 0xFF);
        bytes[3] = @truncate((timestamp_ms >> 16) & 0xFF);
        bytes[4] = @truncate((timestamp_ms >> 8) & 0xFF);
        bytes[5] = @truncate(timestamp_ms & 0xFF);

        bytes[6] = 0x70 | @as(u8, @truncate((rand_a >> 8) & 0x0F));
        bytes[7] = @truncate(rand_a & 0xFF);

        bytes[8] = 0x80 | (rand_b[0] & 0x3F);
        bytes[9] = rand_b[1];
        bytes[10] = rand_b[2];
        bytes[11] = rand_b[3];
        bytes[12] = rand_b[4];
        bytes[13] = rand_b[5];
        bytes[14] = rand_b[6];
        bytes[15] = rand_b[7];

        return .{ .bytes = bytes };
    }

    pub fn v7Now(io: std.Io) std.Io.RandomSecureError!UUID {
        const ts = std.Io.Timestamp.now(io, .real);
        const ms: u48 = @intCast(@divTrunc(ts.nanoseconds, std.time.ns_per_ms));

        var rand_bytes: [12]u8 = undefined;
        try io.randomSecure(&rand_bytes);

        return v7(ms, (@as(u12, rand_bytes[0]) << 4) | (@as(u12, rand_bytes[1]) >> 4), rand_bytes[2..12].*);
    }

    pub fn v8(custom: [16]u8) UUID {
        var bytes = custom;
        bytes[6] = 0x80 | (bytes[6] & 0x0F);
        bytes[8] = 0x80 | (bytes[8] & 0x3F);
        return .{ .bytes = bytes };
    }

    pub fn v2(domain: u8, local_id: u32, node_id: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = 0;
        bytes[1] = 0;
        bytes[2] = 0;
        bytes[3] = 0;

        bytes[4] = @truncate((local_id >> 24) & 0xFF);
        bytes[5] = @truncate((local_id >> 16) & 0xFF);
        bytes[6] = 0x20 | @as(u8, @truncate((local_id >> 8) & 0x0F));
        bytes[7] = @truncate(local_id & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate(domain & 0x3F));
        bytes[9] = 0;

        bytes[10] = node_id[0];
        bytes[11] = node_id[1];
        bytes[12] = node_id[2];
        bytes[13] = node_id[3];
        bytes[14] = node_id[4];
        bytes[15] = node_id[5];

        return .{ .bytes = bytes };
    }

    pub fn timestampV1(self: UUID) u60 {
        return @as(u60, self.bytes[3]) |
            (@as(u60, self.bytes[2]) << 8) |
            (@as(u60, self.bytes[1]) << 16) |
            (@as(u60, self.bytes[0]) << 24) |
            (@as(u60, self.bytes[5]) << 32) |
            (@as(u60, self.bytes[4]) << 40) |
            (@as(u60, self.bytes[7] & 0xFF) << 48) |
            (@as(u60, self.bytes[6] & 0x0F) << 56);
    }

    pub fn timestampV6(self: UUID) u60 {
        return @as(u60, self.bytes[7]) |
            (@as(u60, self.bytes[6] & 0x0F) << 8) |
            (@as(u60, self.bytes[5]) << 12) |
            (@as(u60, self.bytes[4]) << 20) |
            (@as(u60, self.bytes[3]) << 28) |
            (@as(u60, self.bytes[2]) << 36) |
            (@as(u60, self.bytes[1]) << 44) |
            (@as(u60, self.bytes[0]) << 52);
    }

    pub fn timestampV7(self: UUID) u48 {
        return @as(u48, self.bytes[5]) |
            (@as(u48, self.bytes[4]) << 8) |
            (@as(u48, self.bytes[3]) << 16) |
            (@as(u48, self.bytes[2]) << 24) |
            (@as(u48, self.bytes[1]) << 32) |
            (@as(u48, self.bytes[0]) << 40);
    }

    pub fn clockSeq(self: UUID) u14 {
        return @as(u14, self.bytes[8] & 0x3F) << 8 | self.bytes[9];
    }

    pub fn node(self: UUID) [6]u8 {
        return .{ self.bytes[10], self.bytes[11], self.bytes[12], self.bytes[13], self.bytes[14], self.bytes[15] };
    }

    pub fn generateFromHash(ver: Version, namespace: *const [16]u8, name: []const u8) UUID {
        var hash_bytes: [16]u8 = undefined;

        switch (ver) {
            .v3 => {
                var hasher = std.crypto.hash.Md5.init(.{});
                hasher.update(namespace);
                hasher.update(name);
                hasher.final(&hash_bytes);
            },
            .v5 => {
                var hasher = std.crypto.hash.Sha1.init(.{});
                hasher.update(namespace);
                hasher.update(name);
                var full_hash: [20]u8 = undefined;
                hasher.final(&full_hash);
                @memcpy(hash_bytes[0..16], full_hash[0..16]);
            },
            else => unreachable,
        }

        hash_bytes[6] = (hash_bytes[6] & 0x0F) | @as(u8, switch (ver) {
            .v3 => 0x30,
            .v5 => 0x50,
            else => unreachable,
        });
        hash_bytes[8] = (hash_bytes[8] & 0x3F) | 0x80;

        return .{ .bytes = hash_bytes };
    }

    pub fn format(self: UUID, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        const hex = "0123456789abcdef";
        const b = self.bytes;
        const result = [36]u8{
            hex[b[0] >> 4],   hex[b[0] & 0x0F],
            hex[b[1] >> 4],   hex[b[1] & 0x0F],
            hex[b[2] >> 4],   hex[b[2] & 0x0F],
            hex[b[3] >> 4],   hex[b[3] & 0x0F],
            '-',              hex[b[4] >> 4],
            hex[b[4] & 0x0F], hex[b[5] >> 4],
            hex[b[5] & 0x0F], '-',
            hex[b[6] >> 4],   hex[b[6] & 0x0F],
            hex[b[7] >> 4],   hex[b[7] & 0x0F],
            '-',              hex[b[8] >> 4],
            hex[b[8] & 0x0F], hex[b[9] >> 4],
            hex[b[9] & 0x0F], '-',
            hex[b[10] >> 4],  hex[b[10] & 0x0F],
            hex[b[11] >> 4],  hex[b[11] & 0x0F],
            hex[b[12] >> 4],  hex[b[12] & 0x0F],
            hex[b[13] >> 4],  hex[b[13] & 0x0F],
            hex[b[14] >> 4],  hex[b[14] & 0x0F],
            hex[b[15] >> 4],  hex[b[15] & 0x0F],
        };
        try writer.writeAll(&result);
    }

    pub fn encode(self: UUID, buffer: []u8) []u8 {
        const hex = "0123456789abcdef";
        const b = self.bytes;
        const result = [36]u8{
            hex[b[0] >> 4],   hex[b[0] & 0x0F],
            hex[b[1] >> 4],   hex[b[1] & 0x0F],
            hex[b[2] >> 4],   hex[b[2] & 0x0F],
            hex[b[3] >> 4],   hex[b[3] & 0x0F],
            '-',              hex[b[4] >> 4],
            hex[b[4] & 0x0F], hex[b[5] >> 4],
            hex[b[5] & 0x0F], '-',
            hex[b[6] >> 4],   hex[b[6] & 0x0F],
            hex[b[7] >> 4],   hex[b[7] & 0x0F],
            '-',              hex[b[8] >> 4],
            hex[b[8] & 0x0F], hex[b[9] >> 4],
            hex[b[9] & 0x0F], '-',
            hex[b[10] >> 4],  hex[b[10] & 0x0F],
            hex[b[11] >> 4],  hex[b[11] & 0x0F],
            hex[b[12] >> 4],  hex[b[12] & 0x0F],
            hex[b[13] >> 4],  hex[b[13] & 0x0F],
            hex[b[14] >> 4],  hex[b[14] & 0x0F],
            hex[b[15] >> 4],  hex[b[15] & 0x0F],
        };
        @memcpy(buffer[0..36], &result);
        return buffer[0..36];
    }

    pub fn encodeUppercase(self: UUID, buffer: []u8) []u8 {
        const hex = "0123456789ABCDEF";
        const b = self.bytes;
        const result = [36]u8{
            hex[b[0] >> 4],   hex[b[0] & 0x0F],
            hex[b[1] >> 4],   hex[b[1] & 0x0F],
            hex[b[2] >> 4],   hex[b[2] & 0x0F],
            hex[b[3] >> 4],   hex[b[3] & 0x0F],
            '-',              hex[b[4] >> 4],
            hex[b[4] & 0x0F], hex[b[5] >> 4],
            hex[b[5] & 0x0F], '-',
            hex[b[6] >> 4],   hex[b[6] & 0x0F],
            hex[b[7] >> 4],   hex[b[7] & 0x0F],
            '-',              hex[b[8] >> 4],
            hex[b[8] & 0x0F], hex[b[9] >> 4],
            hex[b[9] & 0x0F], '-',
            hex[b[10] >> 4],  hex[b[10] & 0x0F],
            hex[b[11] >> 4],  hex[b[11] & 0x0F],
            hex[b[12] >> 4],  hex[b[12] & 0x0F],
            hex[b[13] >> 4],  hex[b[13] & 0x0F],
            hex[b[14] >> 4],  hex[b[14] & 0x0F],
            hex[b[15] >> 4],  hex[b[15] & 0x0F],
        };
        @memcpy(buffer[0..36], &result);
        return buffer[0..36];
    }

    pub fn encodeCompact(self: UUID, buffer: []u8) []u8 {
        const hex = "0123456789abcdef";
        const b = self.bytes;
        for (0..16) |i| {
            buffer[i * 2] = hex[b[i] >> 4];
            buffer[i * 2 + 1] = hex[b[i] & 0x0F];
        }
        return buffer[0..32];
    }

    pub fn encodeBraced(self: UUID, buffer: []u8) []u8 {
        buffer[0] = '{';
        _ = self.encode(buffer[1..37]);
        buffer[37] = '}';
        return buffer[0..38];
    }

    pub fn encodeUrn(self: UUID, buffer: []u8) []u8 {
        @memcpy(buffer[0..9], "urn:uuid:");
        _ = self.encode(buffer[9..45]);
        return buffer[0..45];
    }

    pub fn toString(self: UUID, allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
        const buf = try allocator.alloc(u8, 36);
        _ = self.encode(buf);
        return buf;
    }

    pub fn sort(uuids: []UUID) void {
        std.mem.sort(UUID, uuids, {}, struct {
            fn lessThan(_: void, a: UUID, b: UUID) bool {
                return a.compare(b) == .lt;
            }
        }.lessThan);
    }
};

pub fn isValid(input: []const u8) bool {
    if (input.len == 36) {
        if (input[8] != '-' or input[13] != '-' or input[18] != '-' or input[23] != '-') return false;
        for (input) |c| {
            if (c == '-') continue;
            if (!((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F'))) return false;
        }
        return true;
    }
    if (input.len == 32) {
        for (input) |c| {
            if (!((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F'))) return false;
        }
        return true;
    }
    if (input.len == 38 and input[0] == '{' and input[37] == '}') {
        return isValid(input[1..37]);
    }
    if (input.len == 45) {
        if (!std.mem.eql(u8, input[0..9], "urn:uuid:")) return false;
        return isValid(input[9..45]);
    }
    return false;
}

test "nil UUID" {
    const testing = std.testing;
    const id = UUID.nil;
    try testing.expect(id.isNil());
    try testing.expectEqual(.nil, id.version());
}

test "max UUID" {
    const testing = std.testing;
    const id = UUID.max;
    try testing.expect(id.isMax());
    try testing.expect(!id.isNil());
}

test "max UUID format" {
    const testing = std.testing;
    var buffer: [36]u8 = undefined;
    const str = UUID.max.encode(&buffer);
    try testing.expectEqualStrings("ffffffff-ffff-ffff-ffff-ffffffffffff", str);
}

test "max UUID parse round-trip" {
    const testing = std.testing;
    const parsed = @import("parse.zig").parse("ffffffff-ffff-ffff-ffff-ffffffffffff") catch unreachable;
    try testing.expect(parsed.isMax());
}

test "version detection" {
    const testing = std.testing;
    var id = UUID{ .bytes = [_]u8{0} ** 16 };
    id.bytes[6] = 0x10;
    try testing.expectEqual(.v1, id.version());
    id.bytes[6] = 0x20;
    try testing.expectEqual(.v2, id.version());
    id.bytes[6] = 0x30;
    try testing.expectEqual(.v3, id.version());
    id.bytes[6] = 0x40;
    try testing.expectEqual(.v4, id.version());
    id.bytes[6] = 0x50;
    try testing.expectEqual(.v5, id.version());
    id.bytes[6] = 0x60;
    try testing.expectEqual(.v6, id.version());
    id.bytes[6] = 0x70;
    try testing.expectEqual(.v7, id.version());
    id.bytes[6] = 0x80;
    try testing.expectEqual(.v8, id.version());
}

test "variant detection" {
    const testing = std.testing;
    var id = UUID{ .bytes = [_]u8{0} ** 16 };
    id.bytes[8] = 0x00;
    try testing.expectEqual(.ncs, id.variant());
    id.bytes[8] = 0x80;
    try testing.expectEqual(.rfc, id.variant());
    id.bytes[8] = 0xC0;
    try testing.expectEqual(.microsoft, id.variant());
    id.bytes[8] = 0xE0;
    try testing.expectEqual(.future, id.variant());
}

test "UUID v1" {
    const testing = std.testing;
    const timestamp: u60 = 0x123456789ABCDEF;
    const clock_seq: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    const id = UUID.v1(timestamp, clock_seq, node);
    try testing.expectEqual(.v1, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expectEqualSlices(u8, &node, id.bytes[10..16]);
}

test "UUID v1 RFC 4122 vector" {
    const testing = std.testing;
    const id = UUID.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("c232ab00-9414-11ec-b3c8-9f6bdec741fb", id.encode(&buffer));
}

test "UUID v4" {
    const testing = std.testing;
    const io: std.Io = std.testing.io;
    const id = try UUID.v4(io);
    try testing.expectEqual(.v4, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expect(!id.isNil());
}

test "UUID v6" {
    const testing = std.testing;
    const timestamp: u60 = 0x123456789ABCDEF;
    const clock_seq: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    const id = UUID.v6(timestamp, clock_seq, node);
    try testing.expectEqual(.v6, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expectEqualSlices(u8, &node, id.bytes[10..16]);
}

test "UUID v6 RFC 9562 vector" {
    const testing = std.testing;
    const id = UUID.v6(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("1ec9414c-232a-6b00-b3c8-9f6bdec741fb", id.encode(&buffer));
}

test "UUID v3 RFC 4122 vector" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.widgets.com");
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("3d813cbb-47fb-32ba-91df-831e1593ac29", id.encode(&buffer));
}

test "UUID v5 RFC 4122 vector" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v5(Namespace.dns, "www.widgets.com");
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("21f7f8de-8051-5b89-8680-0195ef798b6a", id.encode(&buffer));
}

test "UUID v7 RFC 9562 vector" {
    const testing = std.testing;
    const rand_b = [_]u8{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 };
    const id = UUID.v7(0x017F22E279B0, 0xCC3, rand_b);
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("017f22e2-79b0-7cc3-98c4-dc0c0c07398f", id.encode(&buffer));
}

test "UUID v7" {
    const testing = std.testing;
    const timestamp_ms: u48 = 0x123456789ABC;
    const rand_a: u12 = 0x456;
    const rand_b = [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA };
    const id = UUID.v7(timestamp_ms, rand_a, rand_b);
    try testing.expectEqual(.v7, id.version());
    try testing.expectEqual(.rfc, id.variant());
}

test "UUID v7 now" {
    const testing = std.testing;
    const io: std.Io = std.testing.io;
    const id = try UUID.v7Now(io);
    try testing.expectEqual(.v7, id.version());
    try testing.expectEqual(.rfc, id.variant());
}

test "UUID v8" {
    const testing = std.testing;
    const custom = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
    const id = UUID.v8(custom);
    try testing.expectEqual(.v8, id.version());
    try testing.expectEqual(.rfc, id.variant());
}

test "equality" {
    const testing = std.testing;
    const id1 = UUID.v3(@import("namespace.zig").Namespace.dns, "example.com");
    const id2 = UUID.v3(@import("namespace.zig").Namespace.dns, "example.com");
    const id3 = UUID.v3(@import("namespace.zig").Namespace.dns, "other.com");
    try testing.expect(id1.eql(id2));
    try testing.expect(!id1.eql(id3));
}

test "comparison" {
    const testing = std.testing;
    const id1 = UUID.v3(@import("namespace.zig").Namespace.dns, "a.com");
    const id2 = UUID.v3(@import("namespace.zig").Namespace.dns, "b.com");
    try testing.expect(id1.compare(id2) != .eq);
}

test "byte conversion" {
    const testing = std.testing;
    const original = UUID.v3(@import("namespace.zig").Namespace.dns, "test.com");
    const bytes = original.toBytes();
    const restored = UUID.fromBytes(bytes);
    try testing.expect(original.eql(restored));
}

test "integer conversion" {
    const testing = std.testing;
    const id = UUID.v3(@import("namespace.zig").Namespace.dns, "test.com");
    const int_val = id.toU128();
    const restored = UUID.fromU128(int_val);
    try testing.expect(id.eql(restored));
}

test "hash stability" {
    const testing = std.testing;
    const id1 = UUID.v3(@import("namespace.zig").Namespace.dns, "test.com");
    const id2 = UUID.v3(@import("namespace.zig").Namespace.dns, "test.com");
    try testing.expectEqual(id1.hash(), id2.hash());
}

test "v3 and v5 different" {
    const testing = std.testing;
    const id3 = UUID.v3(@import("namespace.zig").Namespace.dns, "test.com");
    const id5 = UUID.v5(@import("namespace.zig").Namespace.dns, "test.com");
    try testing.expect(!id3.eql(id5));
}

test "custom node v1" {
    const testing = std.testing;
    const timestamp: u60 = 0;
    const clock_seq: u14 = 0;
    const node = [6]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
    const id = UUID.v1(timestamp, clock_seq, node);
    try testing.expectEqualSlices(u8, &node, id.bytes[10..16]);
}

test "custom clock sequence v1" {
    const testing = std.testing;
    const timestamp: u60 = 0;
    const clock_seq: u14 = 0x1FFF;
    const node = [_]u8{0} ** 6;
    const id = UUID.v1(timestamp, clock_seq, node);
    try testing.expectEqual(.rfc, id.variant());
}

test "custom timestamp v7" {
    const testing = std.testing;
    const ms: u48 = 0;
    const rand_a: u12 = 0;
    const rand_b = [_]u8{0} ** 10;
    const id = UUID.v7(ms, rand_a, rand_b);
    try testing.expectEqual(.v7, id.version());
}

test "custom v8 payload" {
    const testing = std.testing;
    const custom = [_]u8{0xFF} ** 16;
    const id = UUID.v8(custom);
    try testing.expectEqual(.v8, id.version());
    try testing.expectEqual(.rfc, id.variant());
}

test "different namespaces produce different v3" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id_dns = UUID.v3(Namespace.dns, "test.com");
    const id_url = UUID.v3(Namespace.url, "test.com");
    try testing.expect(!id_dns.eql(id_url));
}

test "encode lowercase" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [36]u8 = undefined;
    const str = id.encode(&buffer);
    const parsed = @import("parse.zig").parse(str) catch unreachable;
    try testing.expect(id.eql(parsed));
}

test "encode uppercase" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [36]u8 = undefined;
    const str = id.encodeUppercase(&buffer);
    try testing.expectEqual(@as(usize, 36), str.len);
    for (str) |c| {
        if (c != '-') {
            try testing.expect((c >= '0' and c <= '9') or (c >= 'A' and c <= 'F'));
        }
    }
}

test "encode compact" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [32]u8 = undefined;
    const str = id.encodeCompact(&buffer);
    try testing.expectEqual(@as(usize, 32), str.len);
}

test "encode braced" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [38]u8 = undefined;
    const str = id.encodeBraced(&buffer);
    try testing.expect(str[0] == '{');
    try testing.expect(str[37] == '}');
}

test "encode URN" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [45]u8 = undefined;
    const str = id.encodeUrn(&buffer);
    try testing.expectEqualStrings("urn:uuid:", str[0..9]);
}

test "format writer" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buf: [256]u8 = undefined;
    var w: std.Io.Writer = .fixed(&buf);
    try id.format(&w);
    const written = w.buffered();
    try testing.expectEqual(@as(usize, 36), written.len);
    const parsed = @import("parse.zig").parse(written) catch unreachable;
    try testing.expect(id.eql(parsed));
}

test "round-trip encode parse" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [36]u8 = undefined;
    const str = id.encode(&buffer);
    const parsed = @import("parse.zig").parse(str) catch unreachable;
    try testing.expect(id.eql(parsed));
}

test "toString allocates" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    const str = try id.toString(testing.allocator);
    defer testing.allocator.free(str);
    try testing.expectEqual(@as(usize, 36), str.len);
    const parsed = @import("parse.zig").parse(str) catch unreachable;
    try testing.expect(id.eql(parsed));
}

test "UUID v2" {
    const testing = std.testing;
    const id = UUID.v2(1, 1000, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    try testing.expectEqual(.v2, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expectEqualSlices(u8, &[_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF }, id.bytes[10..16]);
}

test "timestampV1 round-trip" {
    const testing = std.testing;
    const ts: u60 = 0x1EC9414C232AB00;
    const id = UUID.v1(ts, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    try testing.expectEqual(ts, id.timestampV1());
}

test "timestampV6 round-trip" {
    const testing = std.testing;
    const ts: u60 = 0x1EC9414C232AB00;
    const id = UUID.v6(ts, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    try testing.expectEqual(ts, id.timestampV6());
}

test "timestampV7 round-trip" {
    const testing = std.testing;
    const ts: u48 = 0x017F22E279B0;
    const id = UUID.v7(ts, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
    try testing.expectEqual(ts, id.timestampV7());
}

test "clockSeq round-trip" {
    const testing = std.testing;
    const cs: u14 = 0x1234;
    const id = UUID.v1(0, cs, .{0} ** 6);
    try testing.expectEqual(cs, id.clockSeq());
}

test "node round-trip" {
    const testing = std.testing;
    const n = [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    const id = UUID.v1(0, 0, n);
    try testing.expectEqualSlices(u8, &n, &id.node());
}

test "sort UUIDs" {
    const testing = std.testing;
    var ids = [_]UUID{
        UUID.v3(@import("namespace.zig").Namespace.dns, "c.com"),
        UUID.v3(@import("namespace.zig").Namespace.dns, "a.com"),
        UUID.v3(@import("namespace.zig").Namespace.dns, "b.com"),
    };
    UUID.sort(&ids);
    try testing.expect(ids[0].compare(ids[1]) == .lt);
    try testing.expect(ids[1].compare(ids[2]) == .lt);
}

test "isValid canonical" {
    const testing = std.testing;
    try testing.expect(isValid("550e8400-e29b-41d4-a716-446655440000"));
    try testing.expect(!isValid("550e8400-e29b-41d4-a716-44665544000"));
    try testing.expect(!isValid("550e8400-e29b-41d4-a716-4466554400000"));
    try testing.expect(!isValid("550e8400e29b-41d4-a716-446655440000"));
}

test "isValid compact" {
    const testing = std.testing;
    try testing.expect(isValid("550e8400e29b41d4a716446655440000"));
    try testing.expect(!isValid("550e8400e29b41d4a71644665544000"));
}

test "isValid braced" {
    const testing = std.testing;
    try testing.expect(isValid("{550e8400-e29b-41d4-a716-446655440000}"));
    try testing.expect(!isValid("{550e8400-e29b-41d4-a716-446655440000"));
}

test "isValid URN" {
    const testing = std.testing;
    try testing.expect(isValid("urn:uuid:550e8400-e29b-41d4-a716-446655440000"));
    try testing.expect(!isValid("urn:uuid:550e8400-e29b-41d4-a716-44665544000"));
}

test "isValid invalid chars" {
    const testing = std.testing;
    try testing.expect(!isValid("gggggggg-gggg-gggg-gggg-gggggggggggg"));
    try testing.expect(!isValid("550e8400-e29b-41d4-a716-44665544000g"));
}
