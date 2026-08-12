const std = @import("std");

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

    pub fn toInt(v: Version) u8 {
        return switch (v) {
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
}

test "version fromInt" {
    const testing = std.testing;
    try testing.expectEqual(Version.v1, Version.fromInt(1));
    try testing.expectEqual(Version.v4, Version.fromInt(4));
    try testing.expectEqual(Version.v7, Version.fromInt(7));
    try testing.expectEqual(Version.nil, Version.fromInt(0));
    try testing.expectEqual(Version.unknown, Version.fromInt(99));
}
