const std = @import("std");

pub const Variant = enum {
    ncs,
    rfc,
    microsoft,
    future,

    pub fn fromByte(b: u8) Variant {
        if ((b & 0x80) == 0) return .ncs;
        if ((b & 0xC0) == 0x80) return .rfc;
        if ((b & 0xE0) == 0xC0) return .microsoft;
        return .future;
    }
};

test "variant fromByte" {
    const testing = std.testing;
    try testing.expectEqual(Variant.ncs, Variant.fromByte(0x00));
    try testing.expectEqual(Variant.rfc, Variant.fromByte(0x80));
    try testing.expectEqual(Variant.rfc, Variant.fromByte(0xBF));
    try testing.expectEqual(Variant.microsoft, Variant.fromByte(0xC0));
    try testing.expectEqual(Variant.future, Variant.fromByte(0xE0));
}
