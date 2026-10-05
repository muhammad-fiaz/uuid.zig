//! Core 128-bit UUID value type and its constructors.
//!
//! `UUID` is a 16-byte value type with copy semantics. All instances own
//! their bytes; borrowing a UUID never extends beyond the value itself.
//! Pure constructors (`v1`, `v2`, `v3`, `v5`, `v6`, `v7`, `v8`) allocate
//! nothing and touch no global state, so independent calls are safe to use
//! from any thread. Random constructors (`v4`, `v7Now`) borrow a `std.Io`
//! instance for entropy and time; their thread behavior follows the `Io`
//! implementation supplied by the caller (for example `std.Io.Threaded`).
//!
//! String formatting writes into caller-provided buffers and performs no
//! allocation. Only `toStringAlloc` allocates.

const std = @import("std");
const Version = @import("version.zig").Version;
const Variant = @import("variant.zig").Variant;
const hex = @import("hex.zig");

/// Canonical hyphenated string length (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
pub const canonicalLen: usize = 36;
/// Compact string length without hyphens.
pub const compactLen: usize = 32;
/// Braced string length (`{` + canonical + `}`).
pub const bracedLen: usize = 38;
/// URN string length (`urn:uuid:` + canonical).
pub const urnLen: usize = 45;
/// Raw byte length of a UUID.
pub const byteLen: usize = 16;

/// 128-bit UUID value stored as 16 bytes in network (big-endian) order.
///
/// Bytes map to the string representation left-to-right: `bytes[0]` renders
/// as the first two hex digits. Copying a `UUID` copies all 16 bytes.
pub const UUID = struct {
    bytes: [16]u8,

    /// All-zero (nil) UUID.
    pub const nil: UUID = .{ .bytes = @splat(0) };

    /// All-ones (max) UUID.
    pub const max: UUID = .{ .bytes = @splat(0xFF) };

    /// Reports whether this value is the nil UUID.
    pub fn isNil(self: UUID) bool {
        return self.eql(nil);
    }

    /// Reports whether this value is the max UUID.
    pub fn isMax(self: UUID) bool {
        return self.eql(max);
    }

    /// Returns the version nibble as a `Version`.
    ///
    /// The nil UUID reports `.nil`; any unassigned nibble reports `.unknown`.
    pub fn version(self: UUID) Version {
        const nibble = (self.bytes[6] >> 4) & 0x0F;
        return switch (nibble) {
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

    /// Returns the variant encoded in octet 8.
    pub fn variant(self: UUID) Variant {
        return Variant.fromByte(self.bytes[8]);
    }

    /// Byte-wise equality. UUID values compare by their 16 raw bytes.
    pub fn eql(self: UUID, other: UUID) bool {
        return std.mem.eql(u8, &self.bytes, &other.bytes);
    }

    /// Lexicographic ordering over the 16 raw bytes (big-endian order).
    ///
    /// Suitable for `std.mem.sort` comparators and ordered containers.
    pub fn compare(self: UUID, other: UUID) std.math.Order {
        for (self.bytes, other.bytes) |a, b| {
            if (a < b) return .lt;
            if (a > b) return .gt;
        }
        return .eq;
    }

    /// Copies the raw 16 bytes out of the value.
    pub fn toBytes(self: UUID) [16]u8 {
        return self.bytes;
    }

    /// Wraps 16 raw bytes as a UUID value.
    pub fn fromBytes(bytes: [16]u8) UUID {
        return .{ .bytes = bytes };
    }

    /// Reinterprets the 16 bytes as a `u128` via bit copy.
    ///
    /// This is a raw memory copy, not an RFC integer conversion: byte order
    /// follows the host representation preserved by `@bitCast`. Round-trips
    /// with `fromU128` exactly.
    pub fn toU128(self: UUID) u128 {
        return @as(u128, @bitCast(self.bytes));
    }

    /// Reinterprets a `u128` as 16 UUID bytes via bit copy.
    ///
    /// Inverse of `toU128`; round-trips exactly.
    pub fn fromU128(value: u128) UUID {
        return .{ .bytes = @bitCast(value) };
    }

    /// Deterministic 64-bit hash of the full 128-bit value.
    ///
    /// Uses `std.hash.Wyhash` with seed 0 over the raw bytes, making `UUID`
    /// usable as a hash-map key via `std.AutoHashMap`.
    pub fn hash(self: UUID) u64 {
        return std.hash.Wyhash.hash(0, &self.bytes);
    }

    /// Constructs a time-based (v1) UUID from explicit components.
    ///
    /// All inputs are copied; the caller retains ownership of `nodeId`.
    /// Pure and allocation-free; safe to call from any thread.
    pub fn v1(timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestamp >> 24) & 0xFF);
        bytes[1] = @truncate((timestamp >> 16) & 0xFF);
        bytes[2] = @truncate((timestamp >> 8) & 0xFF);
        bytes[3] = @truncate(timestamp & 0xFF);

        bytes[4] = @truncate((timestamp >> 40) & 0xFF);
        bytes[5] = @truncate((timestamp >> 32) & 0xFF);

        bytes[6] = 0x10 | @as(u8, @truncate((timestamp >> 56) & 0x0F));
        bytes[7] = @truncate((timestamp >> 48) & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate((clockSequence >> 8) & 0x3F));
        bytes[9] = @truncate(clockSequence & 0xFF);

        @memcpy(bytes[10..16], &nodeId);

        return .{ .bytes = bytes };
    }

    /// Constructs a deterministic (v3) UUID by hashing namespace and name with MD5.
    ///
    /// `namespace` and `name` are borrowed. Pure and allocation-free.
    pub fn v3(namespace: UUID, name: []const u8) UUID {
        return generateFromHash(.v3, &namespace.bytes, name);
    }

    /// Generates a cryptographically random (v4) UUID.
    ///
    /// Borrows `io` only for the duration of the call to draw 16 bytes via
    /// `Io.randomSecure`, then sets the version and variant bits. The
    /// returned value is owned by the caller. Thread behavior follows `io`.
    pub fn v4(io: std.Io) std.Io.RandomSecureError!UUID {
        var bytes: [16]u8 = undefined;
        try io.randomSecure(&bytes);
        bytes[6] = 0x40 | (bytes[6] & 0x0F);
        bytes[8] = 0x80 | (bytes[8] & 0x3F);
        return .{ .bytes = bytes };
    }

    /// Constructs a deterministic (v5) UUID by hashing namespace and name with SHA-1.
    ///
    /// `namespace` and `name` are borrowed. Pure and allocation-free.
    pub fn v5(namespace: UUID, name: []const u8) UUID {
        return generateFromHash(.v5, &namespace.bytes, name);
    }

    /// Constructs a reordered time-based (v6) UUID from explicit components.
    ///
    /// Field layout follows RFC 9562 section 5.6 with the timestamp's most
    /// significant bits first for lexicographic sortability. Pure and
    /// allocation-free.
    pub fn v6(timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestamp >> 52) & 0xFF);
        bytes[1] = @truncate((timestamp >> 44) & 0xFF);
        bytes[2] = @truncate((timestamp >> 36) & 0xFF);
        bytes[3] = @truncate((timestamp >> 28) & 0xFF);
        bytes[4] = @truncate((timestamp >> 20) & 0xFF);
        bytes[5] = @truncate((timestamp >> 12) & 0xFF);

        bytes[6] = 0x60 | @as(u8, @truncate((timestamp >> 8) & 0x0F));
        bytes[7] = @truncate(timestamp & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate((clockSequence >> 8) & 0x3F));
        bytes[9] = @truncate(clockSequence & 0xFF);

        @memcpy(bytes[10..16], &nodeId);

        return .{ .bytes = bytes };
    }

    /// Constructs a Unix-epoch time-ordered (v7) UUID from explicit components.
    ///
    /// `timestampMs` holds milliseconds since the Unix epoch; `randA` carries
    /// 12 random bits and the first 8 bytes of `randB` fill octets 8-15.
    /// The final 2 bytes of `randB` are accepted for compatibility but do not
    /// affect the encoded value and should be zero. Pure and allocation-free.
    pub fn v7(timestampMs: u48, randA: u12, randB: [10]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = @truncate((timestampMs >> 40) & 0xFF);
        bytes[1] = @truncate((timestampMs >> 32) & 0xFF);
        bytes[2] = @truncate((timestampMs >> 24) & 0xFF);
        bytes[3] = @truncate((timestampMs >> 16) & 0xFF);
        bytes[4] = @truncate((timestampMs >> 8) & 0xFF);
        bytes[5] = @truncate(timestampMs & 0xFF);

        bytes[6] = 0x70 | @as(u8, @truncate((randA >> 8) & 0x0F));
        bytes[7] = @truncate(randA & 0xFF);

        bytes[8] = 0x80 | (randB[0] & 0x3F);
        bytes[9] = randB[1];
        bytes[10] = randB[2];
        bytes[11] = randB[3];
        bytes[12] = randB[4];
        bytes[13] = randB[5];
        bytes[14] = randB[6];
        bytes[15] = randB[7];

        return .{ .bytes = bytes };
    }

    /// Generates a v7 UUID using the current real time and secure randomness.
    ///
    /// Borrows `io` for the clock (`Io.Timestamp.now(io, .real)`) and for
    /// `Io.randomSecure`. Time is truncated to milliseconds; on truncation
    /// or clock skew no monotonicity across processes is promised beyond
    /// lexicographic time ordering. Thread behavior follows `io`.
    pub fn v7Now(io: std.Io) std.Io.RandomSecureError!UUID {
        const ts = std.Io.Timestamp.now(io, .real);
        // Timestamp is wall-clock nanoseconds; negative values (pre-epoch)
        // wrap via truncation, matching prior behavior for the u48 field.
        const ms: u48 = @intCast(@divTrunc(ts.nanoseconds, std.time.ns_per_ms));

        var randBytes: [12]u8 = undefined;
        try io.randomSecure(&randBytes);

        return v7(ms, (@as(u12, randBytes[0]) << 4) | (@as(u12, randBytes[1]) >> 4), randBytes[2..12].*);
    }

    /// Constructs an application-specific (v8) UUID from a 16-byte payload.
    ///
    /// The payload is copied; version (`0x8`) and variant (`0x80`) bits are
    /// forced so the result always reports `.v8` / `.rfc`. Pure and
    /// allocation-free.
    pub fn v8(custom: [16]u8) UUID {
        var bytes = custom;
        bytes[6] = 0x80 | (bytes[6] & 0x0F);
        bytes[8] = 0x80 | (bytes[8] & 0x3F);
        return .{ .bytes = bytes };
    }

    /// Constructs a DCE Security (v2) UUID from explicit components.
    ///
    /// `domain` selects the interpretation of `localId` (for example POSIX
    /// UID/GID domains); `nodeId` identifies the host. Pure and
    /// allocation-free.
    pub fn v2(domain: u8, localId: u32, nodeId: [6]u8) UUID {
        var bytes: [16]u8 = undefined;

        bytes[0] = 0;
        bytes[1] = 0;
        bytes[2] = 0;
        bytes[3] = 0;

        bytes[4] = @truncate((localId >> 24) & 0xFF);
        bytes[5] = @truncate((localId >> 16) & 0xFF);
        bytes[6] = 0x20 | @as(u8, @truncate((localId >> 8) & 0x0F));
        bytes[7] = @truncate(localId & 0xFF);

        bytes[8] = 0x80 | @as(u8, @truncate(domain & 0x3F));
        bytes[9] = 0;

        @memcpy(bytes[10..16], &nodeId);

        return .{ .bytes = bytes };
    }

    /// Extracts the 60-bit timestamp from a v1 UUID.
    pub fn timestampV1(self: UUID) u60 {
        return @as(u60, self.bytes[3]) |
            (@as(u60, self.bytes[2]) << 8) |
            (@as(u60, self.bytes[1]) << 16) |
            (@as(u60, self.bytes[0]) << 24) |
            (@as(u60, self.bytes[5]) << 32) |
            (@as(u60, self.bytes[4]) << 40) |
            (@as(u60, self.bytes[7]) << 48) |
            (@as(u60, self.bytes[6] & 0x0F) << 56);
    }

    /// Extracts the 60-bit timestamp from a v6 UUID.
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

    /// Extracts the 48-bit Unix-epoch millisecond timestamp from a v7 UUID.
    pub fn timestampV7(self: UUID) u48 {
        return @as(u48, self.bytes[5]) |
            (@as(u48, self.bytes[4]) << 8) |
            (@as(u48, self.bytes[3]) << 16) |
            (@as(u48, self.bytes[2]) << 24) |
            (@as(u48, self.bytes[1]) << 32) |
            (@as(u48, self.bytes[0]) << 40);
    }

    /// Extracts the 14-bit clock sequence from a v1/v6 UUID.
    pub fn clockSeq(self: UUID) u14 {
        return @as(u14, self.bytes[8] & 0x3F) << 8 | self.bytes[9];
    }

    /// Copies the 6-byte node field from a v1/v2/v6 UUID.
    pub fn node(self: UUID) [6]u8 {
        return .{ self.bytes[10], self.bytes[11], self.bytes[12], self.bytes[13], self.bytes[14], self.bytes[15] };
    }

    /// Hashes `namespaceBytes` and `name` into a v3/v5 UUID.
    ///
    /// `namespaceBytes` and `name` are borrowed. Uses MD5 for `.v3` and
    /// SHA-1 (truncated to 128 bits) for `.v5`, then forces the version and
    /// variant bits. Any other `hashVersion` is a programming error and traps.
    pub fn generateFromHash(hashVersion: Version, namespaceBytes: *const [16]u8, name: []const u8) UUID {
        var hashBytes: [16]u8 = undefined;

        switch (hashVersion) {
            .v3 => {
                var hasher = std.crypto.hash.Md5.init(.{});
                hasher.update(namespaceBytes);
                hasher.update(name);
                hasher.final(&hashBytes);
            },
            .v5 => {
                var hasher = std.crypto.hash.Sha1.init(.{});
                hasher.update(namespaceBytes);
                hasher.update(name);
                var fullHash: [20]u8 = undefined;
                hasher.final(&fullHash);
                @memcpy(hashBytes[0..16], fullHash[0..16]);
            },
            else => unreachable,
        }

        hashBytes[6] = (hashBytes[6] & 0x0F) | @as(u8, switch (hashVersion) {
            .v3 => 0x30,
            .v5 => 0x50,
            else => unreachable,
        });
        hashBytes[8] = (hashBytes[8] & 0x3F) | 0x80;

        return .{ .bytes = hashBytes };
    }

    fn writeHexByte(byte: u8, out: *[2]u8, uppercase: bool) void {
        if (uppercase) {
            hex.byteToHexUpper(byte, out);
        } else {
            hex.byteToHex(byte, out);
        }
    }

    fn encodeCanonicalInto(self: UUID, out: []u8, uppercase: bool) void {
        std.debug.assert(out.len >= canonicalLen);
        const b = self.bytes;
        // Hyphen offsets: 8, 13, 18, 23.
        var pos: usize = 0;
        for (b, 0..) |byte, i| {
            if (i == 4 or i == 6 or i == 8 or i == 10) {
                out[pos] = '-';
                pos += 1;
            }
            var pair: [2]u8 = undefined;
            writeHexByte(byte, &pair, uppercase);
            out[pos] = pair[0];
            out[pos + 1] = pair[1];
            pos += 2;
        }
    }

    /// Writes the canonical lowercase form into `buffer` and returns it.
    ///
    /// `buffer` is borrowed and must hold at least 36 bytes; only
    /// `buffer[0..36]` is written and returned. No allocation occurs.
    pub fn encode(self: UUID, buffer: []u8) []u8 {
        encodeCanonicalInto(self, buffer, false);
        return buffer[0..canonicalLen];
    }

    /// Writes the canonical uppercase form into `buffer` and returns it.
    ///
    /// `buffer` is borrowed and must hold at least 36 bytes; only
    /// `buffer[0..36]` is written and returned. No allocation occurs.
    pub fn encodeUppercase(self: UUID, buffer: []u8) []u8 {
        encodeCanonicalInto(self, buffer, true);
        return buffer[0..canonicalLen];
    }

    /// Writes the 32-digit compact form (no hyphens) into `buffer`.
    ///
    /// `buffer` is borrowed and must hold at least 32 bytes; only
    /// `buffer[0..32]` is written and returned. No allocation occurs.
    pub fn encodeCompact(self: UUID, buffer: []u8) []u8 {
        std.debug.assert(buffer.len >= compactLen);
        for (self.bytes, 0..) |byte, i| {
            hex.byteToHex(byte, buffer[i * 2 ..][0..2]);
        }
        return buffer[0..compactLen];
    }

    /// Writes the braced form (`{` + canonical + `}`) into `buffer`.
    ///
    /// `buffer` is borrowed and must hold at least 38 bytes; only
    /// `buffer[0..38]` is written and returned. No allocation occurs.
    pub fn encodeBraced(self: UUID, buffer: []u8) []u8 {
        std.debug.assert(buffer.len >= bracedLen);
        buffer[0] = '{';
        _ = self.encode(buffer[1..37]);
        buffer[37] = '}';
        return buffer[0..bracedLen];
    }

    /// Writes the URN form (`urn:uuid:` + canonical) into `buffer`.
    ///
    /// `buffer` is borrowed and must hold at least 45 bytes; only
    /// `buffer[0..45]` is written and returned. No allocation occurs.
    pub fn encodeUrn(self: UUID, buffer: []u8) []u8 {
        std.debug.assert(buffer.len >= urnLen);
        @memcpy(buffer[0..9], "urn:uuid:");
        _ = self.encode(buffer[9..45]);
        return buffer[0..urnLen];
    }

    /// Formats the canonical lowercase form into `writer`.
    ///
    /// Borrows `writer` only for the duration of the call. Propagates
    /// `Writer.Error` without additional context.
    pub fn format(self: UUID, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        var tmp: [canonicalLen]u8 = undefined;
        _ = self.encode(&tmp);
        try writer.writeAll(&tmp);
    }

    /// Allocates and returns the canonical lowercase string.
    ///
    /// `allocator` is borrowed; the returned 36-byte slice is owned by the
    /// caller and must be freed with `allocator.free`. Only this and the
    /// parsing batch helpers allocate in the core API.
    pub fn toStringAlloc(self: UUID, allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
        const buf = try allocator.alloc(u8, canonicalLen);
        _ = self.encode(buf);
        return buf;
    }

    /// Sorts `uuids` in place in lexicographic (byte) order.
    ///
    /// Borrows and mutates the slice; stable sort via `std.mem.sort`.
    pub fn sort(uuids: []UUID) void {
        std.mem.sort(UUID, uuids, {}, struct {
            fn lessThan(_: void, a: UUID, b: UUID) bool {
                return a.compare(b) == .lt;
            }
        }.lessThan);
    }
};

/// Reports whether `input` has the shape of a supported UUID string.
///
/// Accepts canonical (36), compact (32), braced (38), and URN (45) lengths
/// with correct hyphens/affixes and hex digits (either case). The input is
/// borrowed. This checks shape only; use the `parse*` functions for typed
/// decoding with error details.
pub fn isValid(input: []const u8) bool {
    if (input.len == canonicalLen) {
        if (input[8] != '-' or input[13] != '-' or input[18] != '-' or input[23] != '-') return false;
        for (input) |c| {
            if (c == '-') continue;
            if (!std.ascii.isHex(c)) return false;
        }
        return true;
    }
    if (input.len == compactLen) {
        for (input) |c| {
            if (!std.ascii.isHex(c)) return false;
        }
        return true;
    }
    if (input.len == bracedLen and input[0] == '{' and input[37] == '}') {
        return isValid(input[1..37]);
    }
    if (input.len == urnLen) {
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
    var id: UUID = .{ .bytes = @splat(0) };
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
    var id: UUID = .{ .bytes = @splat(0) };
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
    const clockSequence: u14 = 0x1234;
    const nodeId = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    const id = UUID.v1(timestamp, clockSequence, nodeId);
    try testing.expectEqual(.v1, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expectEqualSlices(u8, &nodeId, id.bytes[10..16]);
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
    const clockSequence: u14 = 0x1234;
    const nodeId = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    const id = UUID.v6(timestamp, clockSequence, nodeId);
    try testing.expectEqual(.v6, id.version());
    try testing.expectEqual(.rfc, id.variant());
    try testing.expectEqualSlices(u8, &nodeId, id.bytes[10..16]);
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
    const randB = [_]u8{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 };
    const id = UUID.v7(0x017F22E279B0, 0xCC3, randB);
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("017f22e2-79b0-7cc3-98c4-dc0c0c07398f", id.encode(&buffer));
}

test "UUID v7 tail bytes are reserved" {
    const testing = std.testing;
    const base = [_]u8{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 };
    const altered = [_]u8{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0xAB, 0xCD };
    const a = UUID.v7(0x017F22E279B0, 0xCC3, base);
    const b = UUID.v7(0x017F22E279B0, 0xCC3, altered);
    try testing.expect(a.eql(b));
}

test "UUID v7" {
    const testing = std.testing;
    const timestampMs: u48 = 0x123456789ABC;
    const randA: u12 = 0x456;
    const randB = [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA };
    const id = UUID.v7(timestampMs, randA, randB);
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
    const intVal = id.toU128();
    const restored = UUID.fromU128(intVal);
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
    const clockSequence: u14 = 0;
    const nodeId = [6]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
    const id = UUID.v1(timestamp, clockSequence, nodeId);
    try testing.expectEqualSlices(u8, &nodeId, id.bytes[10..16]);
}

test "custom clock sequence v1" {
    const testing = std.testing;
    const timestamp: u60 = 0;
    const clockSequence: u14 = 0x1FFF;
    const nodeId: [6]u8 = @splat(0);
    const id = UUID.v1(timestamp, clockSequence, nodeId);
    try testing.expectEqual(.rfc, id.variant());
}

test "custom timestamp v7" {
    const testing = std.testing;
    const ms: u48 = 0;
    const randA: u12 = 0;
    const randB: [10]u8 = @splat(0);
    const id = UUID.v7(ms, randA, randB);
    try testing.expectEqual(.v7, id.version());
}

test "custom v8 payload" {
    const testing = std.testing;
    const custom: [16]u8 = @splat(0xFF);
    const id = UUID.v8(custom);
    try testing.expectEqual(.v8, id.version());
    try testing.expectEqual(.rfc, id.variant());
}

test "different namespaces produce different v3" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const idDns = UUID.v3(Namespace.dns, "test.com");
    const idUrl = UUID.v3(Namespace.url, "test.com");
    try testing.expect(!idDns.eql(idUrl));
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

test "toStringAlloc allocates" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    const str = try id.toStringAlloc(testing.allocator);
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
    const id = UUID.v1(0, cs, @as([6]u8, @splat(0)));
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

test "isValid uppercase compact" {
    const testing = std.testing;
    try testing.expect(isValid("550E8400E29B41D4A716446655440000"));
    try testing.expect(isValid("{550E8400-E29B-41D4-A716-446655440000}"));
}
