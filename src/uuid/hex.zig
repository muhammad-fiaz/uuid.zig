const std = @import("std");
const ParseError = @import("errors.zig").ParseError;

pub fn hexToByte(c: u8) ParseError!u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => error.InvalidCharacter,
    };
}

pub fn byteToHex(b: u8, buf: []u8) void {
    const hex = "0123456789abcdef";
    buf[0] = hex[b >> 4];
    buf[1] = hex[b & 0x0F];
}

pub fn byteToHexUpper(b: u8, buf: []u8) void {
    const hex = "0123456789ABCDEF";
    buf[0] = hex[b >> 4];
    buf[1] = hex[b & 0x0F];
}

test "hexToByte valid" {
    const testing = std.testing;
    try testing.expectEqual(@as(u8, 0), try hexToByte('0'));
    try testing.expectEqual(@as(u8, 9), try hexToByte('9'));
    try testing.expectEqual(@as(u8, 10), try hexToByte('a'));
    try testing.expectEqual(@as(u8, 15), try hexToByte('f'));
    try testing.expectEqual(@as(u8, 10), try hexToByte('A'));
    try testing.expectEqual(@as(u8, 15), try hexToByte('F'));
}

test "hexToByte invalid" {
    const testing = std.testing;
    try testing.expectError(error.InvalidCharacter, hexToByte('g'));
    try testing.expectError(error.InvalidCharacter, hexToByte(' '));
}

test "byteToHex" {
    const testing = std.testing;
    var buf: [2]u8 = undefined;
    byteToHex(0xAB, &buf);
    try testing.expectEqualStrings("ab", &buf);
    byteToHex(0x00, &buf);
    try testing.expectEqualStrings("00", &buf);
    byteToHex(0xFF, &buf);
    try testing.expectEqualStrings("ff", &buf);
}

test "byteToHexUpper" {
    const testing = std.testing;
    var buf: [2]u8 = undefined;
    byteToHexUpper(0xAB, &buf);
    try testing.expectEqualStrings("AB", &buf);
}
