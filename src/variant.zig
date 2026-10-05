//! UUID variant identifiers (RFC 4122 section 4.1.1).
//!
//! The variant is encoded in the most significant bits of octet 8.
//! `Variant` is a value type with no allocation or I/O.

const std = @import("std");

/// UUID variant discriminant derived from octet 8.
pub const Variant = enum {
    /// Reserved, NCS backward compatibility (`0xxxxxxx`).
    ncs,
    /// RFC 4122 / RFC 9562 (`10xxxxxx`).
    rfc,
    /// Reserved, Microsoft compatibility (`110xxxxx`).
    microsoft,
    /// Reserved for future use (`111xxxxx`).
    future,

    /// Classifies the variant bits carried in `byte` (octet 8 of a UUID).
    ///
    /// Only the most significant bits are inspected; remaining bits are ignored.
    pub fn fromByte(byte: u8) Variant {
        if ((byte & 0x80) == 0) return .ncs;
        if ((byte & 0xC0) == 0x80) return .rfc;
        if ((byte & 0xE0) == 0xC0) return .microsoft;
        return .future;
    }
};

test "variant fromByte" {
    const testing = std.testing;
    try testing.expectEqual(Variant.ncs, Variant.fromByte(0x00));
    try testing.expectEqual(Variant.ncs, Variant.fromByte(0x7F));
    try testing.expectEqual(Variant.rfc, Variant.fromByte(0x80));
    try testing.expectEqual(Variant.rfc, Variant.fromByte(0xBF));
    try testing.expectEqual(Variant.microsoft, Variant.fromByte(0xC0));
    try testing.expectEqual(Variant.microsoft, Variant.fromByte(0xDF));
    try testing.expectEqual(Variant.future, Variant.fromByte(0xE0));
    try testing.expectEqual(Variant.future, Variant.fromByte(0xFF));
}
