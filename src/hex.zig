//! Single authoritative hexadecimal helpers for UUID parsing and formatting.
//!
//! Both the parser and the formatter funnel through this module so hex
//! semantics stay consistent. Decoding reuses `std.fmt.charToDigit` for
//! base-16 conversion; validation elsewhere should prefer
//! `std.ascii.isHex`.

const std = @import("std");
const ParseError = @import("errors.zig").ParseError;

/// Decodes one hexadecimal digit.
///
/// Accepts `0-9`, `a-f`, and `A-F`. Any other byte returns
/// `error.InvalidCharacter`. The input is borrowed; nothing is allocated.
pub fn hexToByte(char: u8) ParseError!u8 {
    return std.fmt.charToDigit(char, 16) catch return error.InvalidCharacter;
}

/// Encodes the low-level hex pair for `byte` as lowercase into `out`.
///
/// `out` must have length of at least 2. Only `out[0..2]` is written.
pub fn byteToHex(byte: u8, out: []u8) void {
    std.debug.assert(out.len >= 2);
    const digits = "0123456789abcdef";
    out[0] = digits[byte >> 4];
    out[1] = digits[byte & 0x0F];
}

/// Encodes the low-level hex pair for `byte` as uppercase into `out`.
///
/// `out` must have length of at least 2. Only `out[0..2]` is written.
pub fn byteToHexUpper(byte: u8, out: []u8) void {
    std.debug.assert(out.len >= 2);
    const digits = "0123456789ABCDEF";
    out[0] = digits[byte >> 4];
    out[1] = digits[byte & 0x0F];
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
    try testing.expectError(error.InvalidCharacter, hexToByte('-'));
    try testing.expectError(error.InvalidCharacter, hexToByte('{'));
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
    byteToHexUpper(0x00, &buf);
    try testing.expectEqualStrings("00", &buf);
    byteToHexUpper(0xFF, &buf);
    try testing.expectEqualStrings("FF", &buf);
}

test "hex round-trip" {
    const testing = std.testing;
    var buf: [2]u8 = undefined;
    for (0..256) |i| {
        const byte: u8 = @intCast(i);
        byteToHex(byte, &buf);
        const hi = try hexToByte(buf[0]);
        const lo = try hexToByte(buf[1]);
        try testing.expectEqual(byte, (hi << 4) | lo);
    }
}
