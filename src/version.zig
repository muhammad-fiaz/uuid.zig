//! UUID version identifiers (RFC 4122 / RFC 9562).
//!
//! `Version` is a lightweight value type. The nil UUID reports `.nil`;
//! any nibble without an assigned meaning reports `.unknown`.

const std = @import("std");

/// UUID version discriminant.
pub const Version = enum {
    v1,
    v2,
    v3,
    v4,
    v5,
    v6,
    v7,
    v8,
    nil,
    unknown,

    /// Returns the 4-bit version number stored in octet 6.
    ///
    /// Both `.nil` and `.unknown` map to `0` because neither has an
    /// assigned version nibble.
    pub fn toInt(self: Version) u8 {
        return switch (self) {
            .v1 => 1,
            .v2 => 2,
            .v3 => 3,
            .v4 => 4,
            .v5 => 5,
            .v6 => 6,
            .v7 => 7,
            .v8 => 8,
            .nil => 0,
            .unknown => 0,
        };
    }

    /// Maps a 4-bit nibble to its version discriminant.
    ///
    /// Nibble `0` maps to `.nil`; nibbles above `8` map to `.unknown`.
    /// Callers that need to distinguish nil from unknown should inspect
    /// the UUID value itself via `UUID.isNil`.
    pub fn fromInt(value: u8) Version {
        return switch (value) {
            0 => .nil,
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
};

test "version toInt" {
    const testing = std.testing;
    try testing.expectEqual(@as(u8, 1), Version.v1.toInt());
    try testing.expectEqual(@as(u8, 4), Version.v4.toInt());
    try testing.expectEqual(@as(u8, 7), Version.v7.toInt());
    try testing.expectEqual(@as(u8, 0), Version.nil.toInt());
    try testing.expectEqual(@as(u8, 0), Version.unknown.toInt());
    try testing.expectEqual(@as(u8, 2), Version.v2.toInt());
    try testing.expectEqual(@as(u8, 8), Version.v8.toInt());
}

test "version fromInt" {
    const testing = std.testing;
    try testing.expectEqual(Version.v1, Version.fromInt(1));
    try testing.expectEqual(Version.v4, Version.fromInt(4));
    try testing.expectEqual(Version.v7, Version.fromInt(7));
    try testing.expectEqual(Version.nil, Version.fromInt(0));
    try testing.expectEqual(Version.unknown, Version.fromInt(99));
    try testing.expectEqual(Version.unknown, Version.fromInt(9));
}

test "version round-trip" {
    const testing = std.testing;
    for ([_]Version{ .v1, .v2, .v3, .v4, .v5, .v6, .v7, .v8 }) |ver| {
        try testing.expectEqual(ver, Version.fromInt(ver.toInt()));
    }
}
