const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v8 (Application-Specific) ===\n\n", .{});

    var buf: [36]u8 = undefined;

    std.debug.print("Custom 16-byte payload:\n", .{});
    const custom1 = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
    const id1 = uuid.UUID.v8(custom1);
    std.debug.print("  {s}\n", .{id1.encode(&buf)});
    std.debug.print("  Version: {}, Variant: {}\n", .{ id1.version(), id1.variant() });

    std.debug.print("\nAll zeros payload:\n", .{});
    const custom2 = [_]u8{0} ** 16;
    const id2 = uuid.UUID.v8(custom2);
    std.debug.print("  {s}\n", .{id2.encode(&buf)});
    std.debug.print("  Version: {}, Variant: {}\n", .{ id2.version(), id2.variant() });

    std.debug.print("\nAll ones payload:\n", .{});
    const custom3 = [_]u8{0xFF} ** 16;
    const id3 = uuid.UUID.v8(custom3);
    std.debug.print("  {s}\n", .{id3.encode(&buf)});
    std.debug.print("  Version: {}, Variant: {}\n", .{ id3.version(), id3.variant() });

    std.debug.print("\nv8 is ideal for custom application-specific UUIDs.\n", .{});
    std.debug.print("The version (8) and variant (RFC 4122) bits are set automatically.\n", .{});
}
